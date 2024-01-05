# scripts to download data
include: "downloadData.smk"


# scripts to download gencode data
# TODO::find a way to incorporate this script from a github repo or something
include: "/home/bioinf/bhklab/jermiah/psets/PharmacoSet-Pipelines/workflow/rules/downloadGencode.smk"


scripts_ = ".." /scripts


###############################################################################
# -- Processing CNV data -- #
###############################################################################
rule preprocessCNV:
    input:
        cnv=rawdata / "cnv/CCLE_copynumber_byGene_2013-12-03.txt",
        # ccle_gencode=gencodeAnnotation(
        #     dirPath=metadata,
        #     ref_build=config["gencode_reference"],
        #     gencode_ver=config["ccle_gencode_ver"],
        #     species="human"),
    output:
        preprocessedCNV = procdata / "preprocessedCNV.qs"
    threads:
        4
    script:
        scripts_ / "cnv/preprocessCNV.R"


rule make_CNV_SE:
    input:
        preprocessedCNV = procdata / "preprocessedCNV.qs",
    output:
        CNV_SE = results / "data/CNV_SE.qs"
    threads:
        4
    script:
        scripts_ / "cnv/make_CNV_SE.R"

# preprocessing SNP arrays has not yet been implemented. leaving here for future
rule preprocessSNPArrays:
    input:
        "rawdata/cnv/snpArrays/CEL"
    output:
        preprocessedSNPArrays = procdata / "preprocessedSNPArrays.qs"
    threads:
        4
    script:
        scripts_ / "cnv/preprocessSNPArrays.R"

###############################################################################
# -- Processing Methylation data -- #
###############################################################################

rule make_methylation_SE:
    input:
        methylation = rawdata / "methylation/CCLE_RRBS_TSS1kb_20181022.txt",
        ccle_gencode=gencodeAnnotation(
            dirPath=metadata,
            ref_build=config["gencode_reference"],
            gencode_ver=config["ccle_gencode_ver"],
            species="human"),
    output:
        methylation_SE = results / "data/Methylation_SE.qs"
    threads:
        4
    script:
        scripts_ / "methylation/processMethylation.R"


###############################################################################
# -- Processing Expression data -- #
###############################################################################

rule preprocessExpressionTranscripts:
    input:
        transcripts = rawdata / "expression/CCLE_RNAseq_rsem_transcripts_tpm_20180929.txt",
        ccle_gencode=gencodeAnnotation(
            dirPath=metadata,
            ref_build=config["gencode_reference"],
            gencode_ver=config["ccle_gencode_ver"],
            species="human"),
    output:
        preprocessedExpression = procdata / "preprocessedExpressionTranscripts.qs"
    threads:
        4
    script:
        scripts_ / "expression/preprocessExpressionTranscripts.R"
    
rule preprocessExpressionGenes:
    input:
        genes=rawdata / "expression/CCLE_RNAseq_rsem_genes_tpm_20180929.txt",
        ccle_gencode=gencodeAnnotation(
            dirPath=metadata,
            ref_build=config["gencode_reference"],
            gencode_ver=config["ccle_gencode_ver"],
            species="human"),
    output:
        preprocessedExpression = procdata / "preprocessedExpressionGenes.qs"
    threads:
        4
    script:
        scripts_ / "expression/preprocessExpressionGenes.R"

rule make_ExpressionGenes_SE:
    input:
        preprocessedExpression = procdata / "preprocessedExpressionGenes.qs",
    output:
        processedExpressionGenesSE = results / "data/ExpressionGenes_SE.qs"
    threads:
        4
    script:
        scripts_ / "expression/make_ExpressionGenes_SE.R"


rule make_ExpressionTranscripts_SE:
    input:
        preprocessedExpression = procdata / "preprocessedExpressionTranscripts.qs",
    output:
        processedExpressionTranscriptsSE = results / "data/ExpressionTranscripts_SE.qs"
    threads:
        4
    script:
        scripts_ / "expression/make_ExpressionTranscripts_SE.R"

###############################################################################
# -- Processing Mutation data -- #
###############################################################################

rule preprocessMutation:
    input:
        oncomapAssay=rawdata / "mutation/CCLE_Oncomap3_Assays_2012-04-09.csv",
        oncomap=rawdata / "mutation/CCLE_Oncomap3_2012-04-09.maf",
        hybridCapture=rawdata / "mutation/CCLE_hybrid_capture1650_hg19_NoCommonSNPs_NoNeutralVariants_CDS_2012.05.07.maf",
    output:
        preprocessedMutation = procdata / "preprocessedMutation.qs"
    threads:
        4
    script:
        scripts_ / "mutation/preprocessMutation.R"


rule make_Mutation_SE:
    input:
        preprocessedMutation = procdata / "preprocessedMutation.qs",
    output:
        processedMutationSE = results / "data/Mutation_SE.qs"
    threads:
        4
    script:
        scripts_ / "mutation/make_Mutation_SE.R"