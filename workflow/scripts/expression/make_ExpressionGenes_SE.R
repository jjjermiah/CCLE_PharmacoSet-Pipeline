## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads

    # TODO:: FIX THIS
    DATASET_GENCODE_VERSION <- 19
}

data <- qs::qread(INPUT$preprocessedExpression, nthreads = THREADS)

genes_tpm <- data$genes_tpm

gene_rRanges <- data$gene_rRanges

data.table::setkeyv(genes_tpm, "gene_id")

tpmDf <- genes_tpm[GenomicRanges::mcols(gene_rRanges)[["published.gene_id"]], ]

tpmMatrix <- as.matrix(
    tpmDf[, !c("gene_id", "transcript_ids"), with=FALSE],
    rownames=tpmDf[["gene_id"]]
)

rseGenes_tpm <- SummarizedExperiment::SummarizedExperiment(
    assays = list(genes.tpm = tpmMatrix),
    rowRanges = gene_rRanges,
    colData = data.table::data.table(
        sampleid = colnames(tpmMatrix),
        # make a column called batchid that is full of NAs
        batchid = rep(NA, ncol(tpmMatrix))
    ),
    metadata = data.table::data.table(
        dataset.gencode.version = DATASET_GENCODE_VERSION
    )
)

qs::qsave(rseGenes_tpm, file=OUTPUT$processedExpressionGenesSE, nthreads = THREADS)
