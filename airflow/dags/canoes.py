from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.models import Variable
from datetime import datetime, timedelta

default_args = {
    'owner': 'biodatageeks',
    'depends_on_past': False,
    'start_date': datetime(2017, 10, 18),
    'email': ['team@biodatageeks.ii.pw.edu.pl'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0
}

dag = DAG(
    'canoes', default_args=default_args, schedule_interval=None)

##############################################
########## RUN RAW CANOES CNV CALLER ##########
##############################################

### target qc parameters
mapp_thresh = '0.9'
cov_thresh_from = '20'
cov_thresh_to = '4000'
length_thresh_from = '20'
length_thresh_to = '2000'
gc_thresh_from = '20'
gc_thresh_to = '80'
raw_cov_table = 'input_cov_table.csv'
qc_cov_table = 'output_cov_table.csv'

### select reference sample set parameters
select_method = 'exomedepth' # "canoes", "codex" or "exomedepth"
num_refs = '30'
reference_sample_set_file = 'reference_sample_set.csv'

run_canoes_caller_cmd= " \
docker pull biodatageeks/cnv-opt-target-qc; \
docker run --rm -v /tmp:/tmp -w=\"/tmp\" biodatageeks/cnv-opt-target-qc Rscript -e \"library(\'TARGET.QC\');run_TARGET.QC(" + mapp_thresh + "," + cov_thresh_from + "," + cov_thresh_to + "," + length_thresh_from + "," + length_thresh_to + "," + gc_thresh_from + "," + gc_thresh_to + ",'" + raw_cov_table + "','" + qc_cov_table + "')\"; \
docker pull biodatageeks/cnv-opt-reference-sample-set-selector; \
docker run --rm -v /tmp:/tmp -w=\"/tmp\" biodatageeks/cnv-opt-reference-sample-set-selector Rscript -e \"library(\'REFERENCE.SAMPLE.SET.SELECTOR\');run_REFERENCE.SAMPLE.SET.SELECTOR('" + select_method + "'," + num_refs + ",'" + qc_cov_table + "','" + reference_sample_set_file + "')\"; \
"

run_canoes_caller_task= BashOperator (
    bash_command=run_canoes_caller_cmd,
    task_id='run_canoes_caller_task',
    dag=dag
)

run_canoes_caller_task
