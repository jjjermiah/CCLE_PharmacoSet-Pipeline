from pathlib import Path
import shutil, os
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()


expression = config["molecularProfiles"]["expression"]
mutation = config["molecularProfiles"]["mutation"]
cnv = config["molecularProfiles"]["cnv"]
SNPArrays = config["molecularProfiles"]["cnv"]["SNParrays"]
methylation = config["molecularProfiles"]["methylation"]

logs = Path("logs")



rule downloadExpression:
    input:
        genes_rsem = HTTP.remote(expression["rsem-genes_tpm"]["url"]),
        transcripts_rsem = HTTP.remote(expression["rsem-transcripts_tpm"]["url"]),
        genes_counts = HTTP.remote(expression["genes_counts"]["url"]), 
    output:
        genes_tpm=rawdata / "expression/CCLE_RNAseq_rsem_genes_tpm_20180929.txt",
        transcripts_tpm=rawdata / "expression/CCLE_RNAseq_rsem_transcripts_tpm_20180929.txt",
        genes_counts=rawdata / "expression/CCLE_RNAseq_genes_counts_20180929.gct.gz",
    log:
        logs / "expression/download.log"
    shell:
        # "gunzip {input.genes_rsem} -c > {output.genes_tpm} && gunzip {input.transcripts_rsem} -c > {output.transcripts_tpm}"
        """
        gunzip {input.genes_rsem} -c > {output.genes_tpm} && \
        gunzip {input.transcripts_rsem} -c > {output.transcripts_tpm} && \
        mv {input.genes_counts} {output.genes_counts} > {log} 2>&1
        """

rule downloadMutation:
    input:
        oncomapAssay = HTTP.remote(mutation["oncomapAssay"]["url"]),
        oncomap = HTTP.remote(mutation["oncomap"]["url"]),
        hybridCapture = HTTP.remote(mutation["hybridCapture"]["url"]),
    output:
        oncomapAssay=rawdata / "mutation/CCLE_Oncomap3_Assays_2012-04-09.csv",
        oncomap=rawdata / "mutation/CCLE_Oncomap3_2012-04-09.maf",
        hybridCapture=rawdata / "mutation/CCLE_hybrid_capture1650_hg19_NoCommonSNPs_NoNeutralVariants_CDS_2012.05.07.maf",
    shell:
        """
        mv {input.oncomapAssay} {output.oncomapAssay} && \
        mv {input.oncomap} {output.oncomap} && \
        mv {input.hybridCapture} {output.hybridCapture}
        """

rule downloadMethylation:
    input:
        methylation = HTTP.remote(methylation["RBBS_TSS1kb"]["url"]),
    output:
        methylation=rawdata / "methylation/CCLE_RRBS_TSS1kb_20181022.txt",
    shell:
        """
        gunzip {input.methylation} -c > {output.methylation}
        """


rule downloadCNV:
    input:
        cnv = HTTP.remote(cnv["copynumber_byGene"]["url"]),
    output:
        cnv=rawdata / "cnv/CCLE_copynumber_byGene_2013-12-03.txt",
    shell:
        "gunzip {input.cnv} -c > {output.cnv}"

rule downloadSNPArrays:
    input:
        arrays = [HTTP.remote(SNPArrays[url]) for url in SNPArrays.keys() if url.startswith("url")]
    output:
        arrays=[
            rawdata / "cnv/snpArrays/{}".format(Path(SNPArrays[url]).name) 
                for url in SNPArrays.keys() if url.startswith("url")]
    run:
        for i in range(len(input.arrays)):
            shutil.move(input.arrays[i], output.arrays[i])

rule extractSNPArrays:
    input:
        arrays=[rawdata / "cnv/snpArrays/{}".format(Path(SNPArrays[url]).name) for url in SNPArrays.keys() if url.startswith("url")]
    output:
        directory=directory("rawdata/cnv/snpArrays/CEL")
    threads:
        4
    shell:
        # Run "tar -xvf array --one-top-level={output.directory} for each array
        """
        mkdir -p {output.directory};
        for array in {input.arrays};
        do
            tar -xvf $array -C {output.directory} --strip-components=6 &
        done
        wait $(jobs -p)
        """