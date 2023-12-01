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
head(cnvDt)
ccle_gencode <- rtracklayer::import(INPUT$ccle_gencode)
ccle_gencodeDt <- data.table::as.data.table(ccle_gencode)

checkmate::assert(all(cnvDt$gene_id %in% ccle_gencodeDt$gene_id))

cnvDt <- merge(
    cnvDt, 
    ccle_gencodeDt[type == "gene"], 
    by.x = "gene_id", 
    by.y = "gene_id",
    all.x = TRUE,
    sort = FALSE)


# names(cnvDt)
#    [1] "EGID"                                                                                                
#    [2] "SYMBOL"                                                                                              
#    [3] "CHR"                                                                                                 
#    [4] "CHRLOC"                                                                                              
#    [5] "CHRLOCEND" 

cnvGenomics <- cnvDt[, .(SYMBOL, CHR, CHRLOC, CHRLOCEND, EGID)]

# sort 
egids <- cnvGenomics$EGID
cnvGenomics <- cnvGenomics[order(SYMBOL), ]

cnvGenomics

ccle_gencodeDt[, .(seqnames, start, end, width, strand)]




missing <- setdiff(cnvGenomics$SYMBOL, unique(ccle_gencodeDt[order(gene_name)]$gene_name))
missing
