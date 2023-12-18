## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    LOGFILE <- snakemake@log[[1]]
    save.image()
}
library(data.table)

# set up logging
logger <- log4r::logger(appenders=log4r::file_appender(LOGFILE))

# 1. 
log4r::info(logger,"Reading in preprocessed metadata")
sampleData <- data.table::as.data.table(
    qs::qread(INPUT[["preprocessedMetadata"]])$sample)
sampleData[, CCLE.sampleName := sapply(strsplit(CCLE.sampleID, "_"), function(x) x[1])]

# 2.
log4r::info(logger,"Getting Cellosaurus Accessions for each sample")
cellosaurusAccessions <- 
    AnnotationGx::getCellosaurusAccesions(
        samples = sampleData[, CCLE.sampleName], 
        threads = THREADS)
names(cellosaurusAccessions) <- paste0("Cellosaurus.", c("Accession", "queryField"))

# 3.
log4r::info(logger,"Merging Cellosaurus Accessions into sample metadata")
sampleData <- merge(sampleData, cellosaurusAccessions, by.x = "CCLE.sampleName", by.y = "Cellosaurus.queryField", all.x = TRUE)


# 4.
log4r::info(logger,"Saving output")
qs::qsave(sampleData, file = OUTPUT[[1]])