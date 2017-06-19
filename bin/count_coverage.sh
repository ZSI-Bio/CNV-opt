#!/bin/bash

# ./count_coverage_sample_by_sample_for_codex.sh --coverage-function-file=/home/wiktor/CNV-opt/R/count_coverage_for_single_sample_by_CODEX.R --tmp-dir=/tmp --bam-dir=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS --bed-file=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/EXOME.bed --mapping-quality=20 --chromosome=22 --coverage-file=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/coverage.tsv

for i in "$@"
do
case $i in
    --bam-dir=*)
    BAM_DIR="${i#*=}"
    ;;
    --bed-file=*)
    BED_FILE="${i#*=}"
    ;;
    --mapping-quality=*)
    MAPPING_QUALITY="${i#*=}"
    ;;
    --chromosome=*)
    CHROMOSOME="${i#*=}"
    ;;
    --coverage-file=*)
    COVERAGE_FILE="${i#*=}"
    ;;
    --coverage-function-file=*)
    COVERAGE_FUNCTION_FILE="${i#*=}"
    ;;
    --tmp-dir=*)
    TMP_DIR="${i#*=}"
 ;;
    *)
            # unknown option
    ;;

esac
done



echo "Input directory with bam files: $BAM_DIR"
echo "Bed file: $BED_FILE"
echo "Mapping quality: $MAPPING_QUALITY"
echo "Chromosome: $CHROMOSOME"
echo "Output coverage file: $COVERAGE_FILE"
echo "Coverage function file: $COVERAGE_FUNCTION_FILE"
echo "Temporary directory: $TMP_DIR"

mkdir -p $TMP_DIR
FILES=$BAM_DIR/*.bam
for f in $FILES
do
  echo "Processing $f file..."
  name=$(basename "$f" ".bam")
  COVERAGE_FILE_FOR_SINGLE_SAMPLE=$TMP_DIR/$name"_"$MAPPING_QUALITY"_"$CHROMOSOME"_coverage.txt"
  if [ ! -f $COVERAGE_FILE_FOR_SINGLE_SAMPLE ]
    then
      echo "Processing $name file..."
      Rscript $COVERAGE_FUNCTION_FILE $f $BED_FILE $MAPPING_QUALITY $CHROMOSOME $COVERAGE_FILE_FOR_SINGLE_SAMPLE
  fi

done

mkdir ${COVERAGE_FILE%/*} && touch $COVERAGE_FILE

> $COVERAGE_FILE # clear coverage file
paste -d'\t' $TMP_DIR/*_coverage.txt  >> $COVERAGE_FILE
sed -i 's/ //' $COVERAGE_FILE


