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


cnvDt[1:5,1:6]


# ccle_gencode <- rtracklayer::import(INPUT$ccle_gencode)
# ccle_gencodeDt <- data.table::as.data.table(ccle_gencode)

# cnv_gr <- GenomicRanges::GRanges(
#   seqnames = Rle(cnvDt$CHR),
#   ranges = IRanges(start = cnvDt$CHRLOC, end = cnvDt$CHRLOCEND),
#   strand = Rle("*")  # Assuming strand information is not available in your CNV data
# )


# # Create GRanges for genomic annotation
# annotation_gr <- GenomicRanges::GRanges(
#   seqnames = Rle(ccle_gencodeDt$seqnames),
#   ranges = IRanges(start = ccle_gencodeDt$start, end = ccle_gencodeDt$end),
#   strand = Rle(ccle_gencodeDt$strand)
# )

# # Find overlaps between CNV data and genomic annotation
# overlaps <- findOverlaps(cnv_gr, annotation_gr)
