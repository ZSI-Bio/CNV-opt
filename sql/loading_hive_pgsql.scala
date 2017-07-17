/*run from zsi-bio-spark-shell*/

val createTableString="""CREATE TABLE IF NOT EXISTS  pgsql.coverage_target
USING org.apache.spark.sql.jdbc
OPTIONS (
  url "jdbc:postgresql://cdh00.ii.pw.edu.pl:15432/cnv-opt",
  dbtable "public.coverage_target",
  user 'cnv-opt',
  password 'zsibio321'
)"""

spark.sqlContext.sql(createTableString)

val insertString="""INSERT INTO pgsql.coverage_target SELECT
	chr,
	sample_name,
	target_id,
	pos_min,
	pos_max,
	cov_avg
FROM cnv.coverage_target
"""
spark.sqlContext.sql(insertString)