
## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    save.image()
}


sampleData <- data.table::as.data.table(qs::qread(INPUT[[1]])$sample)
sampleData
