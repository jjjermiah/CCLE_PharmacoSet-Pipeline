## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads

}

library(data.table)
# source the helper function file
snakemake@source("clean_helpers.R")


## 0. read annotation data 
## -------------------------------
sampleDT <- data.table::fread(INPUT$sampleAnnotation)

# fread into treatmentDT and convert column names to safe names
treatmentDT <- data.table::fread(
    input = INPUT$treatmentAnnotation, 
    encoding = "Latin-1")

## 1.0 clean sample annotation data
## -------------------------------
sampleDT <- 
    sampleDT[,
        .(
            CCLE.sampleID = `CCLE_ID`,
            CCLE.name = `Name`,
            CCLE.depMapID = `depMapID`,
            CCLE.site_Primary = `Site_Primary`,
            CCLE.site_Subtype1 = `Site_Subtype1`,
            CCLE.site_Subtype2 = `Site_Subtype2`,
            CCLE.site_Subtype3 = `Site_Subtype3`,
            CCLE.histology = `Histology`,
            CCLE.histology_Subtype1 = `Hist_Subtype1`,
            CCLE.histology_Subtype2 = `Hist_Subtype2`,
            CCLE.histology_Subtype3 = `Hist_Subtype3`,
            CCLE.gender = `Gender`,
            CCLE.age = `Age`,
            CCLE.race = `Race`,
            CCLE.disease = `Disease`,
            CCLE.type = `type`
        )
    ]

sampleDT <- sampleDT[, CCLE.cleanedSampleName := cleanCharacterStrings(CCLE.name)]

## 2.0 clean treatment annotation data
## -------------------------------
# update column names to safe names
treatmentDT <-
    treatmentDT[,
        .(  CCLE.treatmentID = `Compound (code or generic name)`,
            CCLE.target = `Target(s)`,
            CCLE.mechanismOfAction = `Mechanism of action`,
            CCLE.class = `Class`,
            CCLE.highestClinicalTrialPhase = `Highest Phase`,
            CCLE.treatmentSourceOrganization = `Organization`)]

treatmentDT <- 
    treatmentDT[, CCLE.cleanedTreatmentName := cleanCharacterStrings(CCLE.treatmentID)]



## 3.0 write out cleaned data
## -------------------------------

# combine into named list
cleanedData <- list(
    sample = sampleDT,
    treatment = treatmentDT
)

qs::qsave(cleanedData, file = OUTPUT[[1]])


