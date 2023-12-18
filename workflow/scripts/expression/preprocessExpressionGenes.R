

## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    DATASET_GENCODE_VERSION <- 19

}

# Create a Logger object
#### ------------------- Load Data ------------------- ####
print("Loading data")
genes_tpm <- data.table::fread(
    INPUT$genes, 
    header = TRUE, 
    stringsAsFactors = FALSE, 
    sep = "\t") 


genes_tpm_GeneAnnotations <- 
    genes_tpm[, .(published.gene_id = gene_id, transcript_ids)] 

### ------------------- Load GENCODE ------------------- ####
print("Loading GENCODE")
dsGencode <- rtracklayer::import(INPUT$ccle_gencode)
dsGencodeDt <- data.table::as.data.table(dsGencode)

checkmate::assert(all(genes_tpm_GeneAnnotations$published.gene_id %in% dsGencodeDt$gene_id))

print("Merging GENCODE")

gene_rRanges <- merge(
    genes_tpm_GeneAnnotations, 
    dsGencodeDt[type == "gene"], 
    by.x = "published.gene_id", 
    by.y = "gene_id",
    all.x=TRUE,      # 
    sort=FALSE)

print("Creating GRanges")
gene_rRanges <- GenomicRanges::makeGRangesFromDataFrame(gene_rRanges,
                                    keep.extra.columns=TRUE)

output <- list(
    genes_tpm=genes_tpm,
    gene_rRanges=gene_rRanges
)

qs::qsave(output, file=OUTPUT$preprocessedExpression)
