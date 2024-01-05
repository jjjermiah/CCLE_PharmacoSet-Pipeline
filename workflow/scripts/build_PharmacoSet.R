## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    LOGFILE <- snakemake@log[[1]]
    save.image()
}


library(MultiAssayExperiment, quietly = TRUE, warn.conflicts = FALSE)
library(data.table, quietly = TRUE, warn.conflicts = FALSE)
library(PharmacoGx, quietly = TRUE, warn.conflicts = FALSE)

# 1. Metadata
treatment <- qs::qread("procdata/metadata/annotatedTreatmentData.qs")
sample <- qs::qread("procdata/metadata/annotatedSampleData.qs")
sample[, sampleid := CCLE.sampleID]
sample <- sample[!duplicated(sampleid),]

# read in RangedSummarizedExperiment objects
transcripts_SE <- qs::qread(INPUT$transcript_se)
genes_SE <- qs::qread(INPUT$gene_se)
cnv_SE <- qs::qread(INPUT$cnv_se)
mutation_SE <- qs::qread(INPUT$mutation_se)


# combine all colnames from all RangedSummarizedExperiment objects
colnames <- unique(c(
    colnames(transcripts_SE),
    colnames(genes_SE),
    colnames(cnv_SE),
    colnames(mutation_SE)))

# remove all samples in each RangedSummarizedExperiment object that are 
# not in the sample$sampleid column
transcripts_SE <- transcripts_SE[, colnames(transcripts_SE) %in% sample$sampleid]
genes_SE <- genes_SE[, colnames(genes_SE) %in% sample$sampleid]
cnv_SE <- cnv_SE[, colnames(cnv_SE) %in% sample$sampleid]
mutation_SE <- mutation_SE[, colnames(mutation_SE) %in% sample$sampleid]

# convert sample into a dataframe with the sampleid column as rownames
sample <- as.data.frame(sample)
rownames(sample) <- sample$sampleid


# create a MultiAssayExperiment object
colData <- unique(rbind(
    colData(transcripts_SE),
    colData(genes_SE),
    colData(cnv_SE),
    colData(mutation_SE)))


ExpList <- MultiAssayExperiment::ExperimentList(list(
    rnaseq.transcripts = transcripts_SE, 
    rnaseq.genes = genes_SE,
    cnv.genes = cnv_SE,
    mutation.genes = mutation_SE)
)

transcripts_map <- data.frame(
    primary = colData$sampleid,
    colname = colData$sampleid,
    stringsAsFactors = FALSE)

genes_map <- data.frame(
    primary = colData$sampleid,
    colname = colData$sampleid,
    stringsAsFactors = FALSE)

cnv_map <- data.frame(
    primary = colData$sampleid,
    colname = colData$sampleid,
    stringsAsFactors = FALSE)

mutation_map <- data.frame(
    primary = colData$sampleid,
    colname = colData$sampleid,
    stringsAsFactors = FALSE)

sampleMap <- listToMap(list(
    rnaseq.transcripts = transcripts_map,
    rnaseq.genes = genes_map,
    cnv.genes = cnv_map,
    mutation.genes = mutation_map))

mae <- MultiAssayExperiment(
    experiments = ExpList,
    colData = colData,
    sampleMap = sampleMap)


# read in drug response data
tre <- qs::qread("results/data/treatmentResponseExperiment.qs")

pset <- PharmacoGx::PharmacoSet2(
    name = "CCLE",
    treatment = treatment,
    sample = sample,
    molecularProfiles = mae, 
    treatmentResponse = tre,
    curation = list(sample = as.data.frame(sample), treatment = data.frame(), tissue = data.frame())
)

# save PharmacoSet object as qs 
qs::qsave(pset, file=OUTPUT$pset_qs, nthreads = THREADS)

# save PharmacoSet object as RDS
saveRDS(pset, file=OUTPUT$pset_rds)