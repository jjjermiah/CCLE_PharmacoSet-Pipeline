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
# Set up logging
logger <- log4r::logger(
    appenders = log4r::file_appender(LOGFILE, append = TRUE))

# Modify the BiocParallel::MulticoreParam to use the logger
BPPARAM = BiocParallel::MulticoreParam(
    workers = THREADS, progressbar = TRUE, stop.on.error = FALSE)

# 1.
log4r::info(logger,"Reading in mapped sample data")
mappedSampleData <- qs::qread(INPUT[["mappedSampleData"]])

# 2.
data <- BiocParallel::bplapply(
    mappedSampleData[,Cellosaurus.Accession],
    function(x){
        AnnotationGx::searchCellosaurusAPI(
            query=x,
            from="ac",
            format="tsv",
            numResults=1,
            returnURL=F
        )
    },
    BPPARAM = BPPARAM
)

# convert to data.table
data <- data.table::rbindlist(data, fill = TRUE)[, queryField := NULL]
names(data) <- paste0("Cellosaurus.", names(data))

# remove duplicates
data <- data[!duplicated(Cellosaurus.Accession),]

# 3.
sampleData <- merge(
    mappedSampleData, data, by = "Cellosaurus.Accession", all = TRUE)
            

# 4.
qs::qsave(sampleData, OUTPUT[["annotatedSampleData"]])

