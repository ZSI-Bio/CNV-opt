CREATE DATABASE IF NOT EXISTS CNV;
CREATE TABLE IF NOT EXISTS CNV.COVERAGE_RAW (
chr STRING,
pos INT,
coverage_hist ARRAY<INT> COMMENT 'BY DEFAULT [10,20,30,40]',
coverage_total INT
) PARTITIONED BY (sample_name STRING) STORED AS ORC;