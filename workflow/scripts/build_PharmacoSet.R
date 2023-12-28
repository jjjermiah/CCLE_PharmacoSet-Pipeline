## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    LOGFILE <- snakemake@log[[1]]
    save.image()
}
library(MultiAssayExperiment)
library(data.table)


# 1. Metadata
treatment <- qs::qread("procdata/metadata/annotatedTreatmentData.qs")
sample <- qs::qread("procdata/metadata/annotatedSampleData.qs")
sample[, sampleid := CCLE.sampleID]
sample <- sample[!duplicated(sampleid),]
# read in RangedSummarizedExperiment objects
transcripts_SE <- qs::qread("results/data/ExpressionTranscripts_SE.qs")
genes_SE <- qs::qread("results/data/ExpressionGenes_SE.qs")

# convert both to a MultiAssayExperiment

colData <- unique(rbind(
    colData(transcripts_SE),
    colData(genes_SE)))


# create a MultiAssayExperiment object
ExpList <- MultiAssayExperiment::ExperimentList(list(
    rnaseq.transcripts = transcripts_SE, 
    rnaseq.genes = genes_SE)
)

transcripts_map <- data.frame(
    primary = colData$sampleid,
    colname = colData$sampleid,
    stringsAsFactors = FALSE)

genes_map <- data.frame(
    primary = colData$sampleid,
    colname = colData$sampleid,
    stringsAsFactors = FALSE)

sampleMap <- listToMap(list(
    rnaseq.transcripts = transcripts_map,
    rnaseq.genes = genes_map))

mae <- MultiAssayExperiment(
    experiments = ExpList,
    colData = colData,
    sampleMap = sampleMap)


# read in drug response data
tre <- qs::qread("results/data/treatmentResponseExperiment.qs")




PharmacoGx::PharmacoSet2(
    name = "CCLE",
    treatment = treatment,
    sample = sample,
    molecularProfiles = mae, 
    treatmentResponse = tre,
    curation = list(sample = data.frame(), treatment = data.frame(), tissue = data.frame())
)
