## ------------------- Parse Snakemake Object ------------------- ##
if(exists("snakemake")){
    INPUT <- snakemake@input
    OUTPUT <- snakemake@output
       
    WILDCARDS <- snakemake@wildcards
    THREADS <- snakemake@threads
    LOGFILE <- snakemake@log[[1]]

}
library(data.table)

dt <- read.csv(INPUT[["doseResponse"]], stringsAsFactors = FALSE)

# calculate maximum number of doses used in an experiment
# some experiments use less doses so this is necessary to keep dimensions consistent
concentrations.no <- max(sapply(
    dt[ , "Doses..uM."], 
    function(x) length(unlist(strsplit(x, split = ",")))))





#' This function processes treatment response data by converting it into a data.table format.
#'
#' @param values A list containing the treatment response data.
#' @return A data.table containing the processed treatment response data.
#'
#' @details The function takes a list of treatment response data and converts it into a data.table format.
#' It extracts the necessary columns from the input data and performs additional processing steps to
#' transform the data into the desired format. The function also handles missing values by filling them
#' with NA. The resulting data.table contains columns for sample ID, treatment ID, dose, viability,
#' EC50, IC50, Amax, and ActArea.
fnExperiment <- function(values)  {
    # TODO:: dose1...dose8 should correspond exactly to 
    # ".0025,.0080,.025,.080,.25,.80,2.53,8"
    # Fill each empty value with NA
    dt <- data.table(
        sampleID = values[["CCLE.Cell.Line.Name"]],
        treatmentID = values[["Compound"]],
        dose = values[["Doses..uM."]],
        viability = values[["Activity.Data..median."]],
        EC50 = values[["EC50..uM."]],
        IC50 = values[["IC50..uM."]],
        Amax = values[["Amax"]],
        ActArea = values[["ActArea"]]
    )
    # get the doses for a given experiment into the dt
    dt[, paste0("dose", 1:concentrations.no) := {
        doses <- tstrsplit(`dose`, split = ",")
        if (length(doses) < concentrations.no) {
            doses <- c(doses, rep(NA, concentrations.no - length(doses)))
        }
        lapply(doses, function(x) as.numeric(x))
    }]

    # get the responses for a given experiment into the dt
    dt[, paste0("viability", 1:concentrations.no) := {
        responses <- tstrsplit(`viability`, split = ",")
        if (length(responses) < concentrations.no) {
            responses <- c(responses, rep(NA, concentrations.no - length(responses)))
        }
        lapply(responses, function(x) as.numeric(x) + 100)
    }]

    # return dt without the original doses and responses columns
    dt[, c("dose", "viability") := NULL]
    return(dt)
}

# run fnExperiment on each row of dt
dt <- rbindlist(
    BiocParallel::bplapply(
        1:nrow(dt), 
        function(rowNuim) fnExperiment(dt[rowNuim,]),
        BPPARAM = BiocParallel::MulticoreParam(workers = THREADS)))


tdm_ccle <- CoreGx::TREDataMapper(rawdata=dt)

CoreGx::rowDataMap(tdm_ccle) <- list(
    id_columns = c("treatmentID"),
    mapped_columns = c())
CoreGx::colDataMap(tdm_ccle) <- list(
    id_columns = c("sampleID"),
    mapped_columns = c()
)

assays <- list(
    raw = list(c(paste0("dose", 1:8), "sampleID"), paste0("viability", 1:8)),
    profiles = list(c("treatmentID", "sampleID"), c("EC50", "IC50", "Amax", "ActArea"))
)

CoreGx::assayMap(tdm_ccle) <- assays

tre <- CoreGx::metaConstruct(tdm_ccle)


qs::qsave(tre, OUTPUT$treatmentResponse, nthreads = THREADS)
