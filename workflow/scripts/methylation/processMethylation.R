## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    # LOGFILE <- snakemake@log[[1]]
    save.image()
}

methDt <- data.table::fread(
    INPUT$methylation, 
    header = TRUE, 
    stringsAsFactors = FALSE, 
    sep = "\t")
