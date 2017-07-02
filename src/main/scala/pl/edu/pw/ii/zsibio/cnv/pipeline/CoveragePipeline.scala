package pl.edu.pw.ii.zsibio.cnv.pipeline

import java.io.File

import com.typesafe.config.ConfigFactory
import htsjdk.samtools.{SAMFlag, ValidationStringency}
import org.apache.log4j.Logger
import org.apache.spark.sql.SparkSession
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
    sd.getSampleFTPPath(sampleName,SampleType.WES,SampleFileFormat.BAM) match{
      case Some(f) => Some(f.reverse.split("/").head.reverse)
      case _ => None
    }
  }

  private def downloadSample(sampleName:String) = {
    val file = new File(s"${sampleDir}/${getSampleFileName(sampleName).getOrElse(sampleName)}") //FIXME getOrElse smarter
    if (!file.exists()) {
      logger.info(s"Starting downloading sample ${sampleName}")
      if(sd.downloadSample(sampleName, SampleType.WES, SampleFileFormat.BAM, sampleDir) == 0) 0 else -1
    }
    else{
      logger.info(s"Sample ${sampleName} already exists in ${sampleDir}. Skipping...")
      0
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

  private def runCoverage(sampleName:String, samplePath:String) = {
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
    logger.info(s"Finished processing for sample ${sampleName}")
    ss.stop()
  }



  def main(args: Array[String]): Unit = {
    samplesList match {
      case Some(sl) => {
        sl.foreach{
          s => {
            val downloadStatus = downloadSample(s)
            if(downloadStatus == 0){
              logger.info(s"Downloading sample ${s} was successful.")
              getSampleFileName(s) match {
                case Some(file) =>  {
                  val hdfsStatus = copyFromLocal(file,confFile.getString("coverage.hdfs.dir"),false)
                  if(hdfsStatus == 0){
                    logger.info(s"Copying sample file ${file} to HDFS was successful.")
                    runCoverage(s,s"${confFile.getString("coverage.hdfs.dir")}/${file}")

                  }
                  else{
                    logger.error(s"Copying sample ${s} to HDFS failed.")
                  }
                }
                case _ => None
              }

            }
            else logger.error(s"Downloading sample ${s} failed.")


          }
        }
      }
      case _ => None
    }

  }

}
