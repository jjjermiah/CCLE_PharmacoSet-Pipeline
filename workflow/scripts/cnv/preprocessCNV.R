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


# make list of data to save to output
outputData <- list(
    cnvDt = cnvDt,
    cnv_gr = cnv_gr
)

qs::qsave(outputData, file=OUTPUT$preprocessedCNV, nthreads = THREADS)