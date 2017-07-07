#' Function Dexcription
#'
#' Function description.
#' @param cov_file
#' @keywords 
#' @export
#' @examples
#' run_CODEXCOV
run_CODEXCOV <- function(mapp_thresh,
                        cov_thresh_from,
                        cov_thresh_to,
                        length_thresh_from,
                        length_thresh_to,
                        gc_thresh_from,
                        gc_thresh_to,
                        K_from,
                        K_to,
                        lmax,
                        cov_file,
                        sampname_file,
                        bedFile){

  
  ###################################################
  ### code chunk number 0: install0 
  ###################################################
  ## install.packages("RSQLite")
  ## library(RSQLite)
  ## library(DBI)
  
  
  ###################################################
  ### code chunk number 1: install1 (eval = FALSE)
  ###################################################
  ## ## try http:// if https:// URLs are not supported
  #if (length(which(installed.packages() == "CODEX")) == 0){
  #    source("http://bioconductor.org/biocLite.R")
  #    biocLite("CODEX")
  #}
  
  
  ###################################################
  ### code chunk number 2: install2 (eval = FALSE)
  ###################################################
  ## install.packages("devtools")
  ## library(devtools)
  ## install_github("yuchaojiang/CODEX/package")
  
  #source("./R/functions_CODEXCOV.R")   #  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #source("/home/wiktor/CNV-opt/R/functions_CODEX.R")
  
  ###################################################
  ### code chunk number 3: bambedObj1
  ###################################################
  #mapp_thresh <- 0.9
  #cov_thresh_from <- 20
  #cov_thresh_to <- 4000
  #length_thresh_from <- 20
  #length_thresh_to <- 2000
  #gc_thresh_from <- 20
  #gc_thresh_to <- 80
  #K_from <- 1
  #K_to <- 9
  #lmax <- 200  # Maximum CNV length in number of exons returned.
  #cov_file <- file.path("/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/coverage.txt")
  #sampname_file <- "/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/sampname"
  #bedFile <- file.path("/home/wiktor/CNV-opt/data/EXAMPLE_BAMS/EXOME.bed")
  
  #  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  #args = commandArgs(trailingOnly=TRUE)

  #if (length(args) != 13) {
  #  stop("Invalid number of arguments!!!", call.=FALSE)
  #}
  #mapp_thresh <- as.double(args[1])
  #cov_thresh_from <- strtoi(args[2])
  #cov_thresh_to <- strtoi(args[3])
  #length_thresh_from <- strtoi(args[4])
  #length_thresh_to <- strtoi(args[5])
  #gc_thresh_from <- strtoi(args[6])
  #gc_thresh_to <- strtoi(args[7])
  #K_from <- strtoi(args[8])
  #K_to <- strtoi(args[9])
  #lmax <- strtoi(args[10])  # Maximum CNV length in number of exons returned.
  #cov_file <- file.path(args[11])
  #sampname_file <- args[12]
  #bedFile <- file.path(args[13])

  parameters <- data.frame(mapp_thresh, cov_thresh_from, cov_thresh_to, length_thresh_from, length_thresh_to, 
                           gc_thresh_from, gc_thresh_to, K_from, K_to, lmax, cov_file, sampname_file, bedFile)
  
  library(CODEX)
  chrs <- c(1:22, "X", "Y", paste0("chr",c(1:22, "X", "Y")))
  exom_targets <- read.table(bedFile, sep = '\t')
  sampname <- as.matrix(read.table(sampname_file))
  
  for(chr in chrs) {
    exom_targets_for_chr <- exom_targets[exom_targets[,1] == chr,]
    ref <- IRanges(start = exom_targets_for_chr[,2], end = exom_targets_for_chr[,3])
    print(ref)
    if (length(ref) == 0) {    # 0 elements for specified chromosome in bed file
      next()
    }
    
    ###################################################
    ### code chunk number 4: coverageObj1
    ###################################################
    # [TODO] dodac filtr wartosci (wierszy) dla odpowiedniego chromosomu, ale to chyba jest, ale trzeba przetestowac !!!
    Y <- coverageObj1(cov_file, sampname)$Y
    
    ###################################################
    ### code chunk number 5: gcmapp1
    ###################################################
    gcmapp1_result <- gcmapp1(chr, ref)
    gc <- gcmapp1_result$gc
    mapp <- gcmapp1_result$mapp
    
    ###################################################
    ### code chunk number 6: qcObj1
    ###################################################
    qcObj1_result <- qcObj1(Y, sampname, chr, ref, mapp, gc, cov_thresh = c(cov_thresh_from, cov_thresh_to), 
                        length_thresh = c(length_thresh_from, length_thresh_to), mapp_thresh, 
                        gc_thresh = c(gc_thresh_from, gc_thresh_to))
    Y_qc <- qcObj1_result$Y_qc
    sampname_qc <- qcObj1_result$sampname_qc
    gc_qc <- qcObj1_result$gc_qc
    ref_qc <- qcObj1_result$ref_qc
    
    ###################################################
    ### code chunk number 7: normObj1
    ###################################################
    normObj_result <- normObj1(Y_qc, gc_qc, K = K_from:K_to)
    Yhat <- normObj_result$Yhat
    AIC <- normObj_result$AIC
    BIC <- normObj_result$BIC
    RSS <- normObj_result$RSS
    K <- normObj_result$K
    
    ###################################################
    ### code chunk number 8: normObj2 (eval = FALSE)
    ###################################################
    ## normObj_result <- normObj2(Y_qc, gc_qc, K = 1:9, normal_index=seq(1,45,2))
    ## Yhat <- normObj_result$Yhat
    ## AIC <- normObj_result$AIC
    ## BIC <- normObj_result$BIC
    ## RSS <- normObj_result$RSS
    ## K <- normObj_result$K
    
    
    ###################################################
    ### code chunk number 9: choiceofK (eval = FALSE)
    ###################################################
    #choiceofK(AIC, BIC, RSS, K, filename = paste("choiceofK_", chr, ".pdf", sep = ""))
    
    
    ###################################################
    ### code chunk number 10: fig1
    ###################################################
    #plot(K, RSS, type = "b", xlab = "Number of latent variables")
    #plot(K, AIC, type = "b", xlab = "Number of latent variables")
    #plot(K, BIC, type = "b", xlab = "Number of latent variables")
    
    
    ###################################################
    ### code chunk number 11: segment1
    ###################################################
    finalcallIt <- segment1(Y_qc, Yhat, K[which.max(BIC)], K, sampname_qc,
                            ref_qc, chr, lmax, mode = "integer")$finalcall
   if (nrow(finalcall)==0){finalcall <- matrix(nrow=0, ncol=ncol(finalcallIt))} 
    finalcall <- rbind(finalcall, finalcallIt)
  
  }
  finalcall
  
  
  
  
  
  
  
  library(DBI)
  db <- dbConnect(drv=RSQLite::SQLite(), dbname="db.sqlite")
  
  if (!dbExistsTable(db, name="parameters")) {
    dbSendQuery(db,
          "CREATE TABLE parameters(
          id INTEGER PRIMARY KEY,
          mapp_thresh TEXT,
          cov_thresh_from TEXT,
          cov_thresh_to TEXT,
          length_thresh_from TEXT,
          length_thresh_to TEXT,
          gc_thresh_from TEXT,
          gc_thresh_to TEXT,
          K_from TEXT,
          K_to TEXT,
          lmax TEXT,
          cov_file TEXT,
          sampname_file TEXT,
          bedFile TEXT
        );"
    )
  }
  dbWriteTable(db, name="parameters", value=data.frame(parameters), append=TRUE)
  #dbGetQuery(db, 'SELECT * FROM parameters')
  parameters_id <- nrow(dbReadTable(db,'parameters'))
  
  if (!dbExistsTable(db, name="calls")) {
    dbSendQuery(db,
          "CREATE TABLE calls(
          id INTEGER PRIMARY KEY,
          parameters_id INTEGER,
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
          FOREIGN KEY(parameters_id) REFERENCES parameters(id)
        );"
    )
  }
  dbWriteTable(db, name="calls", value=data.frame(cbind(finalcall, parameters_id=parameters_id)), append=TRUE)
  #dbGetQuery(db, 'SELECT * FROM calls')
  
  
  dbDisconnect(db)
  #unlink("db.sqlite")
}