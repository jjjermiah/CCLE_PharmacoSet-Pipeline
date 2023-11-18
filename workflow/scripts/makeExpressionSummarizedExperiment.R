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

data <- qs::qread(INPUT$preprocessedExpression, nthreads = THREADS)


## ------------------- Make Genes SE ------------------- ##

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
        sample.id = colnames(tpmMatrix)
    ),
    metadata = data.table::data.table(
        dataset.gencode.version = DATASET_GENCODE_VERSION
    )
)

## ------------------- Make Transcripts SE ------------------- ##

transcripts_tpm <- data$transcripts_tpm

transcript_rRanges <- data$transcript_rRanges

data.table::setkeyv(transcripts_tpm, "transcript_id")

tpmDf <- transcripts_tpm[GenomicRanges::mcols(transcript_rRanges)[["transcript_id"]], ]

tpmMatrix <- as.matrix(
    tpmDf[, !c("gene_id", "transcript_id"), with=FALSE],
    rownames=tpmDf[["transcript_id"]]
)

rseTranscript_tpm <- SummarizedExperiment::SummarizedExperiment(
    assays = list(transcripts.tpm = tpmMatrix),
    rowRanges = transcript_rRanges,
    colData = data.table::data.table(
        sample.id = colnames(tpmMatrix)
    ),
    metadata = data.table::data.table(
        dataset.gencode.version = DATASET_GENCODE_VERSION
    )
)
SEs <- list(
    genes = rseGenes_tpm,
    transcripts = rseTranscript_tpm
)

qs::qsave(SEs, file=OUTPUT$procssedExpressionSE, nthreads = THREADS)
