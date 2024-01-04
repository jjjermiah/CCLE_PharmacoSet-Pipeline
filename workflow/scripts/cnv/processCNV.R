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

cnvDt <- data.table::fread(
    INPUT$cnv, 
    header = TRUE, 
    stringsAsFactors = FALSE, 
    sep = "\t")



###################################################################
## Note: Leaving this here so gene annotation can be properly aligned and 
# used instead of the default annotation from the processed CNV data file.

# ccle_gencode <- rtracklayer::import(INPUT$ccle_gencode)
# ccle_gencodeDt <- data.table::as.data.table(ccle_gencode)
# # Create GRanges for genomic annotation
# annotation_gr <- GenomicRanges::GRanges(
#   seqnames = Rle(ccle_gencodeDt$seqnames),
#   ranges = IRanges::IRanges(start = ccle_gencodeDt$start, end = ccle_gencodeDt$end),
#   strand = Rle(ccle_gencodeDt$strand)
# )

# # Find overlaps between CNV data and genomic annotation
# overlaps <- findOverlaps(cnv_gr, annotation_gr)

# TODO:: figure out how to proceed from here and use the gene annotation

cnv_seqnames <- paste0("chr", cnvDt$CHR)


cnv_gr <- GenomicRanges::GRanges(
  seqnames = S4Vectors::Rle(cnv_seqnames),
  ranges = IRanges::IRanges(start = cnvDt$CHRLOC, end = cnvDt$CHRLOCEND),
  strand = S4Vectors::Rle("*")  # Assuming strand information is not available in your CNV data
)


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
