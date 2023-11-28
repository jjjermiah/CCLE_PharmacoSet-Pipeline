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

qs::qsave(rseTranscript_tpm, file=OUTPUT$processedExpressionTranscriptsSE, nthreads = THREADS)
