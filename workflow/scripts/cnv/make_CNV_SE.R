## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads

    # TODO:: FIX THIS
    DATASET_GENCODE_VERSION <- 19
    save.image()
}
library(data.table)

data <- qs::qread(INPUT$preprocessedCNV, nthreads = THREADS)

cnvDt <- data$cnvDt
cnv_gr <- data$cnv_gr


#### CREATE SUMMARIZED EXPERIMENT
# Create a RangedSummarizedExperiment object

cnv_matrix <- as.matrix(
    cnvDt[, -c("EGID", "SYMBOL", "CHR", "CHRLOC", "CHRLOCEND"), with=FALSE],
    rownames=cnvDt[["SYMBOL"]]
)

cnv_se <- SummarizedExperiment::SummarizedExperiment(
    assays = list(cnv.genes = cnv_matrix),
    rowRanges = cnv_gr,
    colData = data.table::data.table(
        sampleid = colnames(cnv_matrix),
        # make a column called batchid that is full of NAs
        batchid = rep(NA, ncol(cnv_matrix))
    ),
    metadata = data.table::data.table(
        dataset.gencode.version = DATASET_GENCODE_VERSION
    )
)


qs::qsave(cnv_se, file=OUTPUT$CNV_SE, nthreads = THREADS)
