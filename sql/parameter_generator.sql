--create backup
create table test_params_bck as select * from test_parameters;

--generate
create table test_parameters_chr as 
select row_number() over () as id, 
  caller ,
  cov_table ,
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
from test_params_bck par, (select cast (generate_series(1,22) as text) as chr
union
select 'X'
union
select 'Y') chr;
