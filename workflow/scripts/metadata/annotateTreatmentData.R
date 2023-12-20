library(data.table)
## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads

}


treatmentMetadata <- data.table::as.data.table(qs::qread(INPUT[[1]])$treatment)


BPPARAM = BiocParallel::MulticoreParam(workers = THREADS, progressbar = TRUE, stop.on.error = FALSE)


## 1. Get PubChem CIDs for all treatment names
## -------------------------------------------
message("Getting PubChem CIDs from all treatment names")

getCID <- function(names){
    AnnotationGx::getPubChemCompound(
        names,
        from='name',
        to='cids',
        batch = FALSE,
        verbose = FALSE,
        BPPARAM = BPPARAM, raw = F)}
    
compound_nameToCIDS <- getCID(treatmentMetadata[, CCLE.cleanedTreatmentName])

# remove duplicates and modify names to match treatmentMetadata
compound_nameToCIDS <- compound_nameToCIDS[
    !duplicated(name), 
    .(CCLE.cleanedTreatmentName = `name`, PubChem.CID = `cids`)]

# # note: as of writing, CCLE has no failed queries. 
# failed <- attributes(compound_nameToCIDS)$failed 

# merge PubChem CIDs into treatmentMetadata
treatmentMetadata <- merge(
    treatmentMetadata, compound_nameToCIDS, 
    by = "CCLE.cleanedTreatmentName", all.x = TRUE)


if(length(treatmentMetadata[is.na(treatmentMetadata$PubChem.CID), CCLE.cleanedTreatmentName]) > 0){
    message("WARNING: Some PubChem CIDs could not be found:")
    message(treatmentMetadata[is.na(PubChem.CID), CCLE.cleanedTreatmentName])
}

## 2. Get PubChem Properties from CIDS
## -----------------------------------
message("Getting PubChem Properties from CIDS")
propertiesFromCID <- 
    AnnotationGx::getPubChemCompound(
        treatmentMetadata[, PubChem.CID], 
        from='cid', 
        to='property', 
        properties=c('Title', 'MolecularFormula', 'InChIKey', 'CanonicalSMILES'),
        BPPARAM = BPPARAM)

names(propertiesFromCID) <- sapply(names(propertiesFromCID), function(x) paste0("PubChem.",x))

treatmentMetadata <- merge(
    treatmentMetadata, propertiesFromCID, 
    by.x = "PubChem.CID", by.y="PubChem.CID", all.x = TRUE)

# ## 3. Get PubChem Synonyms from CIDS
# ## ---------------------------------
# NOTE: SYNONYMS ARE VERY MESSY AND NOT USEFUL
# message("Getting PubChem Synonyms from CIDS")
# CIDtoSynonyms <- 
#     AnnotationGx::getPubChemCompound(
#         treatmentMetadata[, PubChem.CID], 
#         from='cid', 
#         to='synonyms')

# names(CIDtoSynonyms) <- sapply(names(CIDtoSynonyms), function(x) paste0("PubChem.",x))

# treatmentMetadata <- merge(
#     treatmentMetadata, CIDtoSynonyms, by.x = "PubChem.CID", by.y="PubChem.CID", all.x = TRUE)

## 4. Get PubChem Annotations from CIDS
## ------------------------------------


annotations <- c('ChEMBL ID', 'NSC Number', 'Drug Induced Liver Injury', 'CAS', 'ATC Code')

getPubChemAnnotationsMultipleCID <- function(CIDs, annotations, dropCID = FALSE) {
    result <- BiocParallel::bplapply(
        CIDs,
        AnnotationGx::getPubChemAnnotations,
        annotations = annotations,
        BPPARAM = BPPARAM
    )
    # combine results into a single data.table and remove duplicates
    result <- data.table::rbindlist(result, fill = TRUE)[!duplicated(cid), ]

    # by using data.table notation to run this command on each row 
    # we can drop the cid column 
    if (dropCID) result[, "cid" := NULL]
    return(result)
}


message("Getting External PubChem Annotations from CIDS")
treatmentMetadata[, paste0("PubChem.", make.names(annotations)) := 
    getPubChemAnnotationsMultipleCID(PubChem.CID, annotations, TRUE)]

# 5. Get ChEMBL Mechanism from ChEMBL ID
# --------------------------------------
message("Getting ChEMBL Mechanism from ChEMBL ID")
x <- AnnotationGx::getChemblMechanism(treatmentMetadata$"PubChem.ChEMBL.ID")[!duplicated(`Molecule Chembl ID`),]
names(x) <- paste0("ChEMBL.", make.names(names(x)))

treatmentMetadata <- merge(treatmentMetadata, x, by.x = "PubChem.ChEMBL.ID", by.y = "ChEMBL.Molecule.Chembl.ID", all=T)

qs::qsave(treatmentMetadata, file = OUTPUT[[1]])

file <- "/home/bioinf/bhklab/jermiah/psets/PharmacoSet-Pipelines/CCLE/metadata/annotatedTreatments.tsv"

data.table::fwrite(treatmentMetadata, file = file, quote = F, sep = "\t")
