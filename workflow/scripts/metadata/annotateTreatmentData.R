
## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    save.image()
}


treatmentMetadata <- data.table::as.data.table(qs::qread(INPUT[[1]])$treatment)


BPPARAM = BiocParallel::MulticoreParam(workers = THREADS, progressbar = TRUE, stop.on.error = FALSE)


## 1. Get PubChem CIDs for all treatment names
## -------------------------------------------
message("running getPubChemCompound using all names")

compound_nameToCIDS <-
    AnnotationGx::getPubChemCompound(
        treatmentMetadata[, CCLE.cleanedTreatmentName],
        from='name',
        to='cids',
        batch = FALSE,
        verbose = FALSE,
        BPPARAM = BPPARAM
    )


compound_nameToCIDS <- compound_nameToCIDS[
    !duplicated(name), 
    .(CCLE.cleanedTreatmentName = `name`, PubChem.CID = `cids`)]

failed <- attributes(compound_nameToCIDS)$failed # note: as of writing, CCLE has no failed queries. 

treatmentMetadata <- merge(
    treatmentMetadata, compound_nameToCIDS, by = "CCLE.cleanedTreatmentName", all.x = TRUE)


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
    treatmentMetadata, propertiesFromCID, by.x = "PubChem.CID", by.y="PubChem.CID", all.x = TRUE)


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
annotations <- annotations[1:2]
getPubChemAnnotationsMultipleCID <- function(CIDs, annotations){
    result <- data.table::rbindlist(BiocParallel::bplapply(
        CIDs, 
        AnnotationGx::getPubChemAnnotations, 
        annotations = annotations,
        BPPARAM = BPPARAM
    ))
    # drop the "cids" column
    result <- result[!duplicated(cid), ]
    names(result) <- make.names(names(result))
    result[, "cid" := NULL]
}

message("Getting External PubChem Annotations from CIDS")
treatmentMetadata[, paste0("PubChem.", annotations) := getPubChemAnnotationsMultipleCID(PubChem.CID, annotations)]
treatmentMetadata

save.image()
