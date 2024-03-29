package pl.edu.pw.ii.zsibio.cnv.pipeline

import java.io.{File, FileOutputStream, PrintWriter}

import com.typesafe.config.ConfigFactory
import htsjdk.samtools.{SAMFlag, ValidationStringency}
import it.unimi.dsi.fastutil.booleans.BooleanSets.EmptySet
import org.apache.log4j.Logger
import org.apache.spark.sql.SparkSession
import org.rogach.scallop.ScallopConf
import pl.edu.pw.ii.zsibio.coverage.{CoverageHistParam, CoverageHistType, SeqContext}
import pl.edu.pw.ii.zsibio.utils.hdfs.HDFSUtils
import pl.edu.pw.ii.zsibio.utils.samples.{SampleFileFormat, SampleType}
import pl.edu.pw.ii.zsibio.utils.samples.download.data1000genomes.Downloader1000Genomes
import pl.edu.pw.ii.zsibio.coverage.CoverageFunctionsSlim._
import pl.edu.pw.ii.zsibio.coverage.CoverageReadFunctions._

import scala.io.Source
/**
  * Created by marek on 30/06/2017.
  */
object CoveragePipeline {
  class RunConf(args:Array[String]) extends ScallopConf(args){

    val sampleName =opt[String]("sampleName",required = true, descr = "Sample to process" )

    verify()
  }

  val logger = Logger.getLogger(getClass.getName)
  /*samples downloader*/
  val confFile = ConfigFactory.load()
  val sd = new Downloader1000Genomes()

  val samplesFile = s"${confFile.getString("coverage.conf.dir")}/samples.txt"
  val samplesList = getSamplesFromFile(samplesFile)
  val sampleDir = s"${confFile.getString("coverage.sample.dir")}/"




  private def getSamplesFromFile(file:String) = {
    try {
      Some(Source.fromFile(file).getLines.toArray)
    }
    catch {
      case e: Exception => None
    }
  }

  private def getSampleFileName(sampleName:String) = {
    sd.ftp.connectWithAuth(sd.server)
    sd.getSampleFTPPath(sampleName,SampleType.WES,SampleFileFormat.BAM) match{
      case Some(f) => Some(f.reverse.split("/").head.reverse)
      case _ => None
    }
  }

  private def downloadSample(sampleName:String) : Int  = {

    val file = new File(s"${sampleDir}/${getSampleFileName(sampleName).getOrElse(sampleName)}") //FIXME getOrElse smarter
    if (!file.exists()) {
      logger.info(s"Starting downloading sample ${sampleName}")
      sd.ftp.connectWithAuth(sd.server)
      val status = sd.downloadSample(sampleName, SampleType.WES, SampleFileFormat.BAM, sampleDir)
      sd.disconnect
      return status
    }
    else{
      logger.info(s"Sample ${sampleName} already exists in ${sampleDir}. Skipping...")
      return 0
    }
  }
  private def copyFromLocal(file:String, target:String, overwrite:Boolean) = {

    if(HDFSUtils.ls(target,false).filter(_.getPath.getName.matches(file)).length == 1 && !overwrite){
      logger.info(s"${file} exists on HDFS and overwrite flag is set to false so skipping...")
    }
    else {
      logger.info(s"Copying ${file} to HDFS path ${target}")
      HDFSUtils.copyFromLocal(s"${sampleDir}${file}", target, overwrite)
    }
    HDFSUtils.ls(target,false).filter(_.getPath.getName.matches(file)).length match {
      case 1 => 0
      case _ => -1
    }
  }

  private def runCoverage(sampleName:String, samplePath:String) : Int = {
    val ss = SparkSession
      .builder()
      .appName(s"CNV-OPT coverage sample:${sampleName}")
      .enableHiveSupport()
      .getOrCreate()
    val seqContext = new SeqContext(ss.sparkContext)
    val coverageReadRDD = seqContext
      .loadSamples(samplePath,ValidationStringency.LENIENT)
    logger.info(s"Starting coverage calculation for sample ${sampleName}")
    val coverageRDD = coverageReadRDD
      .filter(r=> (r.samFlags & SAMFlag.READ_UNMAPPED.intValue) == 0 )
      .filter(r=>r.mapq != 255)
      .baseCoverageHist(None,Some(512),CoverageHistParam(CoverageHistType.MAPQ,Array(10,20,30,40)))
    ss.sqlContext.sql("set parquet.compression=GZIP")
    val df = ss.sqlContext.createDataFrame(coverageRDD)
    df.createOrReplaceTempView("cov")
    val insertStmt =  s"""
                         |INSERT OVERWRITE TABLE ${confFile.getString("coverage.hive.raw.table")} PARTITION (sample_name='${sampleName}')
                         |SELECT * FROM cov
      """.stripMargin
    logger.debug(s"Running ${insertStmt}")
    ss.sqlContext.sql(insertStmt)
    val sanityCheckStmt =
      s"""
         | SELECT COUNT(*) AS CNT FROM  ${confFile.getString("coverage.hive.raw.table")} WHERE sample_name='${sampleName}'
       """.stripMargin
    val samplePartCount = ss.sqlContext.sql(sanityCheckStmt).first().getAs[Long]("CNT")
    if(samplePartCount > 0) {
      logger.info(s"Successfully finished processing for sample ${sampleName}")
      HDFSUtils.rm(samplePath)
      logger.info(s"File ${samplePath} deleted.")
      return 0
    }
    else logger.error(s"Processing of sample ${sampleName} failed.")
    ss.stop()
    return -1
  }



  def main(args: Array[String]): Unit = {
    val runConf = new RunConf(args)
    Some(Array(runConf.sampleName())) match {
      case Some(sl) => {
        sl.foreach {
          s => {
            val processedSamples = getSamplesFromFile(confFile.getString("coverage.checkpoint.file")) match {
              case Some(ps) => ps.toSet
              case _ => Set.empty[String]
            }

            if (!processedSamples.contains(s)) {
              logger.info(s"Starting processing sample ${s}")
              val downloadStatus = downloadSample(s)
              if (downloadStatus == 0) {
                logger.info(s"Downloading sample ${s} was successful.")
                getSampleFileName(s) match {
                  case Some(file) => {
                    val hdfsStatus = copyFromLocal(file, confFile.getString("coverage.hdfs.dir"), false)
                    if (hdfsStatus == 0) {
                      logger.info(s"Copying sample file ${file} to HDFS was successful.")
                      if (runCoverage(s, s"${confFile.getString("coverage.hdfs.dir")}/${file}") == 0) {
                        val localFile = new File(s"${sampleDir}/${file}")
                        if (localFile.exists())
                          if (localFile.delete()) {
                            logger.info(s"File ${file} deleted from ${sampleDir}")
                            val write = new PrintWriter(new FileOutputStream(new File(confFile.getString("coverage.checkpoint.file")),true))
                            write.append(s"${s}\n")
                            write.flush()
                            write.close()
                          }
                          else logger.error(s"Deleting of ${file} failed")
                      }

                    }
                    else {
                      logger.error(s"Copying sample ${s} to HDFS failed.")
                    }
                  }
                  case _ => None
                }

              }
              else logger.error(s"Downloading sample ${s} failed.")


            }
            else {
              logger.info(s"Sample ${s} already processed and checkpointed, skipping....")
            }
          }
        }
      }
      case _ => None
    }

  }

}
