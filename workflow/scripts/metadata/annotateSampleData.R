## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    LOGFILE <- snakemake@log[[1]]
    save.image()
}
# 0. 
# Setup
library(data.table)
logger <- log4r::logger(
    appenders = list(
        log4r::file_appender(LOGFILE, append = TRUE),
        log4r::console_appender()
    )
)

# Modify the BiocParallel::MulticoreParam to use the logger
BPPARAM = BiocParallel::MulticoreParam(
    workers = THREADS, progressbar = TRUE, stop.on.error = FALSE)

# 1.
log4r::info(logger,"Reading in mapped sample data")
mappedSampleData <- qs::qread(INPUT[["mappedSampleData"]])

# 2.
log4r::info(logger,"Annotating sample data")
data <- AnnotationGx::mapCellosaursAccessionsToFields(
    mappedSampleData$Cellosaurus.Accession, 
    fields = c("id", "ac", "sy", "ca", "sx", "ag", "di", "derived-from-site", "misspelling"),
)

save.image()
log4r::info(logger,"Finished annotating sample data")

names(data) <- paste0("Cellosaurus.", names(data))
data <- data[!duplicated(Cellosaurus.Accession),]

# 3.
log4r::info(logger,"Removing duplicates")
sampleData <- merge(
    mappedSampleData, data, by = "Cellosaurus.Accession", all = TRUE)
            

# 4.
log4r::info(logger,"Saving annotated sample data")
qs::qsave(sampleData, OUTPUT[["annotatedSampleData"]])

