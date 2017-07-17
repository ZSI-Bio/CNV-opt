--create backup
create table test_params_bck as select * from test_parameters;

--generate
drop table if exists test_parameters_chr;
create table test_parameters_chr as 
select cast(row_number() over () as integer ) as id, 
  caller ,
  cast('public.coverage_target' as text) as cov_table,
  mapp_thresh ,
  cov_thresh_from ,
  cov_thresh_to ,
  length_thresh_from ,
  length_thresh_to ,
  gc_thresh_from ,
  gc_thresh_to ,
  k_from ,
  k_to ,
  lmax,
  chr
from test_params_bck par, (select cast (generate_series(1,22) as text ) as chr
union
select 'X'
union
select 'Y') chr;

--delete from test_parameters_chr where chr<>'Y'

---create coverage table in postgres
CREATE TABLE coverage_target(
  chr text, 
  sample_name , 
  target_id int, 
  pos_min int, 
  pos_max int, 
  cov_avg numeric);

 ALTER TABLE public.coverage_target OWNER TO "cnv-opt"; 
CREATE INDEX coveage_targe_idx1 ON coverage_target(chr);



