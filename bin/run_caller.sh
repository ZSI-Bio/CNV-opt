#!/bin/bash

# ./run_caller.sh --caller=codex --conf-file=./../conf/caller.yaml --caller-path=./../R/run_CODEX.R --coverage-file=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/coverage.tsv --bed-file=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/EXOME.bed --sample-names-file=/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/sampname

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

for i in "$@"
do
case $i in
    --caller=*)
    CALLER="${i#*=}"
    ;;
    --conf-file=*)
    CONF_FILE="${i#*=}"
    ;;
    --caller-path=*)
    CALLER_PATH="${i#*=}"
    ;;
    --coverage-file=*)
    COVERAGE_FILE="${i#*=}"
    ;;
    --bed-file=*)
    BED_FILE="${i#*=}"
    ;;
    --sample-names-file=*)
    SAMPLE_NAMES_FILE="${i#*=}"
 ;;
    *)
            # unknown option
    ;;

esac
done

echo "Caller: $CALLER"
echo "Configuration file: $CONF_FILE"
echo "Caller path: $CALLER_PATH"

eval $(parse_yaml $CONF_FILE)
CALLER=$(echo "$CALLER" | tr '[:lower:]' '[:upper:]')

if [ $CALLER == "CODEX" ]
then
  echo "CODEX caller..."
  # TODO zmienic na nazwane parametry
  Rscript $CALLER_PATH $codex_mapp_thresh $codex_cov_thresh_from $codex_cov_thresh_to $codex_length_thresh_from $codex_length_thresh_to $codex_gc_thresh_from $codex_gc_thresh_to $codex_k_from $codex_k_to $codex_lmax $COVERAGE_FILE $SAMPLE_NAMES_FILE $BED_FILE
elif [ $CALLER == "XHMM" ]
then
  echo "XHMM caller..."
  # TODO
else
  echo "Unknown CNV caller..."
fi





