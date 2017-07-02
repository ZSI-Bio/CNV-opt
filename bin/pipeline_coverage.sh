#!/bin/bash
export SPARK_HOME=/data/local/opt/spark-2.1.1-bin-hadoop2.6
export PATH=$SPARK_HOME/bin:$PATH
spark-submit --master yarn-client --driver-memory 1g --executor-memory 2500m --num-executors 96  --class  pl.edu.pw.ii.zsibio.cnv.pipeline.CoveragePipeline /data/local/projects/git/forks/CNV-opt/target/scala-2.11/cnv-opt-assembly-0.1.jar
