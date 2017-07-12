CREATE DATABASE CNV;
\connect cnv
CREATE SCHEMA IF NOT EXISTS CNV;

CREATE TABLE IF NOT EXISTS CNV.PARAMETERS (
    id SERIAL PRIMARY KEY,
    mapp_thresh TEXT,
    cov_thresh_from TEXT,
    cov_thresh_to TEXT,
    length_thresh_from TEXT,
    length_thresh_to TEXT,
    gc_thresh_from TEXT,
    gc_thresh_to TEXT,
    K_from TEXT,
    K_to TEXT,
    lmax TEXT
);

CREATE TABLE IF NOT EXISTS CNV.CALLS (
    id SERIAL PRIMARY KEY,
    parameters_id INT,
    sample_name TEXT,
    chr TEXT,
    cnv TEXT,
    st_bp TEXT,
    ed_bp TEXT,
    length_kb TEXT,
    st_exon TEXT,
    ed_exon TEXT,
    raw_cov TEXT,
    norm_cov TEXT,
    copy_no TEXT,
    lratio TEXT,
    mBIC TEXT,
    FOREIGN KEY(parameters_id) REFERENCES CNV.PARAMETERS(id)
);
