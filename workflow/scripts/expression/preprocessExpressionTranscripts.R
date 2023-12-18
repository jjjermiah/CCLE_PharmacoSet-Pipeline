

## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    DATASET_GENCODE_VERSION <- 19

}

# Create a Logger object
print("Loading data")
transcripts_tpm <- data.table::fread(
    INPUT$transcripts, 
    header = TRUE, 
    stringsAsFactors = FALSE, 
    sep = "\t")

transcripts_tpm_GeneAnnotations <- 
    transcripts_tpm[, .(published.gene_id = gene_id, transcript_id = transcript_id)]

### ------------------- Load GENCODE ------------------- ####
print("Loading GENCODE")
dsGencode <- rtracklayer::import(INPUT$ccle_gencode)
dsGencodeDt <- data.table::as.data.table(dsGencode)

checkmate::assert(all(transcripts_tpm_GeneAnnotations$published.gene_id %in% dsGencodeDt$gene_id))


print("Merging GENCODE")
# create granges
transcript_rRanges <- merge(
    transcripts_tpm_GeneAnnotations, 
    dsGencodeDt[type == "transcript"], 
    by="transcript_id", 
    all.x=TRUE,      # 
    sort=FALSE)

print("Creating GRanges")
transcript_rRanges <- GenomicRanges::makeGRangesFromDataFrame(transcript_rRanges, 
                                    keep.extra.columns=TRUE)
output <- list(
    transcripts_tpm=transcripts_tpm,
    transcript_rRanges=transcript_rRanges
)

qs::qsave(output, file=OUTPUT$preprocessedExpression)
