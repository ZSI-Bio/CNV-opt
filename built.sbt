import scala.util.Properties

name := """cnv-opt"""

version := "0.1-SNAPSHOT"


organization := "pl.edu.pw.ii.zsibio"

scalaVersion := "2.11.8"

val DEFAULT_SPARK_2_VERSION = "2.1.0.cloudera1"
val DEFAULT_HADOOP_VERSION = "2.6.0-cdh5.11.0"
val ZSI_BIO_SPARK_1_VERSION= "1.6.4-SNAPSHOT"


lazy val sparkVersion = Properties.envOrElse("SPARK_VERSION", DEFAULT_SPARK_2_VERSION)
lazy val hadoopVersion = Properties.envOrElse("SPARK_HADOOP_VERSION", DEFAULT_HADOOP_VERSION)

fork := true

javaOptions in run ++= Seq(
  "-Dlog4j.debug=true",
  "-Dlog4j.configuration=log4j.properties")


updateOptions := updateOptions.value.withLatestSnapshots(false)

outputStrategy := Some(StdoutOutput)

libraryDependencies ++= Seq(
  "org.scalatest" % "scalatest_2.11" % "3.0.0" % "test",
  "org.apache.spark" % "spark-core_2.11" % sparkVersion % "provided"
  /*excludeAll ExclusionRule(organization = "javax.servlet")*/,
  "org.apache.spark" % "spark-sql_2.11" % sparkVersion  % "provided"  excludeAll ExclusionRule(organization = "javax.servlet")
    excludeAll ExclusionRule(organization = "org.apache.parquet.schema"),
  "org.apache.spark" % "spark-hive_2.11" % sparkVersion % "provided"  excludeAll ExclusionRule(organization = "javax.servlet")
    excludeAll ExclusionRule(organization = "org.apache.parquet.schema"),
  "org.apache.spark" % "spark-mllib_2.11" % sparkVersion  % "provided"  excludeAll ExclusionRule(organization = "javax.servlet"),
  "org.apache.hadoop" % "hadoop-common" % hadoopVersion % "provided",
  "org.apache.hadoop" % "hadoop-client" % hadoopVersion % "provided"
    excludeAll ExclusionRule(organization = "javax.servlet"),
  "org.rogach" %% "scallop" % "3.0.3",
  "com.holdenkarau" % "spark-testing-base_2.11" % "2.1.0_0.6.0" % "test"
    exclude("org.apache.spark", "spark-core_2.11")
    exclude("org.apache.spark", "spark-sql_2.11"),
  "pl.edu.pw.ii.zsibio" % "common-routines_2.11" % "0.1-SNAPSHOT",
  "com.typesafe" % "config" % "1.3.1",
  "log4j" % "log4j" % "1.2.17"
)

resolvers ++= Seq(
  "Job Server Bintray" at "https://dl.bintray.com/spark-jobserver/maven",
  "zsibio-snapshots" at "http://zsibio.ii.pw.edu.pl:50007/repository/maven-snapshots/",
  "spring" at "http://repo.spring.io/libs-milestone/"
)

parallelExecution in Test := false

assemblyMergeStrategy in assembly := {
  case PathList("org", "apache", "commons", xs@_*) => MergeStrategy.first
  /*case PathList("scala", xs@_*) => MergeStrategy.first
    a nasty workaround!!!
  case PathList("org", xs@_*) => MergeStrategy.first
  case PathList("javax", xs@_*) => MergeStrategy.first
  end*/
  case PathList("fi", "tkk", "ics", xs@_*) => MergeStrategy.first
  case PathList("com", "esotericsoftware", xs@_*) => MergeStrategy.first
  case PathList("org", "objectweb", xs@_*) => MergeStrategy.last
  case PathList("javax", "xml", xs@_*) => MergeStrategy.first
  case PathList("javax", "servlet", xs@_*) => MergeStrategy.first
  case PathList("javax", "annotation", xs@_*) => MergeStrategy.first
  case PathList("javax", "activation", xs@_*) => MergeStrategy.first
  case PathList("javax", "transaction", xs@_*) => MergeStrategy.first
  case PathList("javax", "mail", xs@_*) => MergeStrategy.first
  case PathList("com", "twitter", xs@_*) => MergeStrategy.first
  case PathList("org", "slf4j", xs@_*) => MergeStrategy.first
  //META-INF/maven/com.google.guava/guava/pom.xml
  // Added
  case PathList("htsjdk", xs@_*) => MergeStrategy.first
  case PathList("org", "apache", "bcel", xs@_*) => MergeStrategy.first
  case PathList("org", "apache", "regexp", xs@_*) => MergeStrategy.first
  case PathList("io", "netty", xs@_*) => MergeStrategy.first
  case PathList("com", "codahale", "metrics", xs@_*) => MergeStrategy.first
  case PathList("com", "google", "common", xs@_*) => MergeStrategy.first
  case PathList("org", "apache", "spark", "unused", xs@_*) => MergeStrategy.first
  case PathList("edu", "umd", "cs", "findbugs", xs@_*) => MergeStrategy.first
  case PathList("net", "jcip", "annotations", xs@_*) => MergeStrategy.first
  case PathList("org", "apache", "jasper", xs@_*) => MergeStrategy.first
  case "parquet.thrift" => MergeStrategy.first
  case PathList(ps@_*) if ps.last endsWith ".html" => MergeStrategy.first
  case "application.conf" => MergeStrategy.concat
  case PathList("org", "apache", "hadoop", xs@_*) => MergeStrategy.first
  //case "META-INF/ECLIPSEF.RSA"     => MergeStrategy.discard
  case "META-INF/mimetypes.default" => MergeStrategy.first
  case ("META-INF/ECLIPSEF.RSA") => MergeStrategy.first
  case ("META-INF/mailcap") => MergeStrategy.first
  case ("plugin.properties") => MergeStrategy.first
  case ("META-INF/maven/org.slf4j/slf4j-api/pom.xml") => MergeStrategy.first
  case ("META-INF/maven/com.google.guava/guava/pom.xml") => MergeStrategy.first
  case ("META-INF/maven/org.slf4j/slf4j-api/pom.properties") => MergeStrategy.first
  // case ("META-INF/io.netty.versions.properties") => MergeStrategy.first
  case x if x.endsWith("io.netty.versions.properties") => MergeStrategy.first
  case x if x.endsWith("pom.properties") => MergeStrategy.first
  case x if x.endsWith("pom.xml") => MergeStrategy.first
  case x if x.endsWith("plugin.xml") => MergeStrategy.first
  //case ("META-INF/maven/com.google.guava/guava/pom.xml") => MergeStrategy.first
  case ("log4j.properties") => MergeStrategy.first
  case ("git.properties") => MergeStrategy.first
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}




credentials += Credentials(Path.userHome / ".ivy2" / ".credentials")
publishTo := {
  val nexus = "http://zsibio.ii.pw.edu.pl:50007/repository/"
  if (isSnapshot.value)
    Some("snapshots" at nexus + "maven-snapshots")
  else
    Some("releases" at nexus + "maven-releases")
}
