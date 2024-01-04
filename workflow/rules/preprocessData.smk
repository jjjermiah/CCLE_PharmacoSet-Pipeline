# scripts to download data
include: "downloadData.smk"


# scripts to download gencode data
# TODO::find a way to incorporate this script from a github repo or something
include: "/home/bioinf/bhklab/jermiah/psets/PharmacoSet-Pipelines/workflow/rules/downloadGencode.smk"


scripts_ = ".." /scripts

rule make_CNV_SE:
    input:
        cnv=rawdata / "cnv/CCLE_copynumber_byGene_2013-12-03.txt",
        ccle_gencode=gencodeAnnotation(
            dirPath=metadata,
            ref_build=config["gencode_reference"],
            gencode_ver=config["ccle_gencode_ver"],
            species="human"),
    output:
        CNV_SE = results / "data/CNV_SE.qs"
    threads:
        4
    script:
        scripts_ / "cnv/processCNV.R"

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

rule preprocessMutation:
    input:
        oncomapAssay=rawdata / "mutation/CCLE_Oncomap3_Assays_2012-04-09.csv",
        oncomap=rawdata / "mutation/CCLE_Oncomap3_2012-04-09.maf",
    output:
        preprocessedMutation = procdata / "preprocessedMutation.qs"
    threads:
        4
    script:
        scripts_ / "mutation/preprocessMutation.R"

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