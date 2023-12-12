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

# conda install -c bioconda bioconductor-pd.genomewidesnp.6 bioconductor-oligo bioconductor-affyio

path <- "/home/bioinf/bhklab/jermiah/psets/PharmacoSet-Pipelines/CCLE/rawdata/cnv/snpArrays/CEL"
fileList <- list.files(path, pattern = ".CEL", full.names = TRUE)

# batch variable represents the group of samples that were processed together
# "rawdata/cnv/snpArrays/CEL/SKATS_p_NCLE_DNAAffy13_GenomeWideSNP_6_C06_592854.CEL" 
# in this example, SKATS is the batch variable
batch <- gsub(pattern = ".*\\/|\\.CEL", "", fileList)
# get the first element after splitting on "_"
batch <- sapply(strsplit(batch, "_"), function(x) x[1])
# batch

# Need to set OMP_NUM_THREADS to 1 to avoid error: 
# ERROR; return code from pthread_create() is 22

cnSet <- crlmm::constructAffyCNSet(
    filenames = fileList[1:50], 
    batch = batch[1:50], 
    cdfName = "genomewidesnp6",
    verbose = T, 
    genome = "hg18")

Sys.setenv("OMP_NUM_THREADS" = "1")
checkmate::assert(crlmm::cnrmaAffy(cnSet))
crlmm::snprmaAffy(cnSet)

# checkmate::assert(crlmm::genotypeAffy(data))
print(cnSet)
print(object.size(cnSet), units="Mb")

crlmm::crlmmCopynumber(cnSet, verbose = T)

# # data <- affy::read.affybatch(fileList[1:5], cdfname = "pd.genomewidesnp.6")
data <- oligo::read.celfiles(fileList[1:5], pkgname = "pd.genomewidesnp.6")
# data


#####
source("https://bioconductor.org/biocLite.R")
biocLite("pd.genomewidesnp.6")
library(oligo)
library(pd.genomewidesnp.6)

devtools::install_github("Crick-CancerGenomics/ascat/ASCAT")
devtools::install_github("mskcc/facets")

install.packages("https://bioconductor.org/packages/3.14/bioc/src/contrib/copynumber_1.34.0.tar.gz")
pak::pkg_install("cran/sequenza")
BiocManager::install(c("affxparser", "Biostrings", "aroma.light", "BSgenome", "copynumber", "GenomicRanges", "limma", "rhdf5", "sequenza"))
pak::pkg_install("gustaveroussy/EaCoN")

install.packages("https://zenodo.org/record/5494853/files/affy.CN.norm.data_0.1.2.tar.gz", repos = NULL, type = "source")
pkg::pkg_install("gustaveroussy/apt.snp6.1.20.0")

install.packages("https://zenodo.org/record/5494853/files/GenomeWideSNP.6.na35.r1_0.1.0.tar.gz", repos = NULL, type = "source")
install.packages("https://zenodo.org/record/5494853/files/rcnorm_0.1.5.tar.gz", repos = NULL, type = "source")

