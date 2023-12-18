# scripts to download data
include: "downloadData.smk"


# scripts to download gencode data
# TODO::find a way to incorporate this script from a github repo or something
include: "/home/bioinf/bhklab/jermiah/psets/PharmacoSet-Pipelines/workflow/rules/downloadGencode.smk"


scripts_ = ".." /scripts



rule preprocessCNV:
    input:
        cnv=rawdata / "cnv/CCLE_copynumber_byGene_2013-12-03.txt",
        ccle_gencode=gencodeAnnotation(
            dirPath=metadata,
            ref_build=config["gencode_reference"],
            gencode_ver=config["ccle_gencode_ver"],
            species="human"),
    output:
        preprocessedCNV = procdata / "preprocessedCNV.qs"
    threads:
        4
    script:
        scripts_ / "cnv/preprocessCNV.R"

rule preprocessSNPArrays:
    input:
        directory("rawdata/cnv/snpArrays/CEL")
    output:
        preprocessedSNPArrays = procdata / "preprocessedSNPArrays.qs"
    threads:
        4
    script:
        scripts_ / "cnv/preprocessSNPArrays.R"


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