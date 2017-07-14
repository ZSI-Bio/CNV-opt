CREATE TABLE IF NOT EXISTS TEST_PARAMETERS (
    id SERIAL PRIMARY KEY,
    caller TEXT,
    cov_table TEXT,
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

INSERT INTO TEST_PARAMETERS VALUES (1, 'codex', 'cnv.coverage_target', 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
INSERT INTO TEST_PARAMETERS VALUES (2, 'codex', 'cnv.coverage_target', 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
INSERT INTO TEST_PARAMETERS VALUES (3, 'codex', 'cnv.coverage_target', 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
INSERT INTO TEST_PARAMETERS VALUES (4, 'codex', 'cnv.coverage_target', 5, 6, 7, 8, 9, 10, 11, 12, 13, 14);
INSERT INTO TEST_PARAMETERS VALUES (5, 'codex', 'cnv.coverage_target', 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
INSERT INTO TEST_PARAMETERS VALUES (6, 'codex', 'cnv.coverage_target', 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
INSERT INTO TEST_PARAMETERS VALUES (7, 'codex', 'cnv.coverage_target', 8, 9, 10, 11, 12, 13, 14, 15, 16, 17);
INSERT INTO TEST_PARAMETERS VALUES (8, 'codex', 'cnv.coverage_target', 9, 10, 11, 12, 13, 14, 15, 16, 17, 18);
INSERT INTO TEST_PARAMETERS VALUES (9, 'codex', 'cnv.coverage_target', 10, 11, 12, 13, 14, 15, 16, 17, 18, 19);
INSERT INTO TEST_PARAMETERS VALUES (10, 'xhmm', 'cnv.coverage_target', 11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
INSERT INTO TEST_PARAMETERS VALUES (11, 'xhmm', 'cnv.coverage_target', 12, 13, 14, 15, 16, 17, 18, 19, 20, 21);
INSERT INTO TEST_PARAMETERS VALUES (12, 'xhmm', 'cnv.coverage_target', 13, 14, 15, 16, 17, 18, 19, 20, 21, 22);
INSERT INTO TEST_PARAMETERS VALUES (13, 'xhmm', 'cnv.coverage_target', 14, 15, 16, 17, 18, 19, 20, 21, 22, 23);
INSERT INTO TEST_PARAMETERS VALUES (14, 'xhmm', 'cnv.coverage_target', 15, 16, 17, 18, 19, 20, 21, 22, 23, 24);
INSERT INTO TEST_PARAMETERS VALUES (15, 'xhmm', 'cnv.coverage_target', 16, 17, 18, 19, 20, 21, 22, 23, 24, 25);
INSERT INTO TEST_PARAMETERS VALUES (16, 'xhmm', 'cnv.coverage_target', 17, 18, 19, 20, 21, 22, 23, 24, 25, 26);
INSERT INTO TEST_PARAMETERS VALUES (17, 'xhmm', 'cnv.coverage_target', 18, 19, 20, 21, 22, 23, 24, 25, 26, 27);
INSERT INTO TEST_PARAMETERS VALUES (18, 'xhmm', 'cnv.coverage_target', 19, 20, 21, 22, 23, 24, 25, 26, 27, 28);
INSERT INTO TEST_PARAMETERS VALUES (19, 'xhmm', 'cnv.coverage_target', 20, 21, 22, 23, 24, 25, 26, 27, 28, 29);
INSERT INTO TEST_PARAMETERS VALUES (20, 'xhmm', 'cnv.coverage_target', 21, 22, 23, 24, 25, 26, 27, 28, 29, 30);

CREATE TABLE IF NOT EXISTS TEST_CALLS (
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
    FOREIGN KEY(parameters_id) REFERENCES TEST_PARAMETERS(id)
);

INSERT INTO TEST_CALLS VALUES (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);
