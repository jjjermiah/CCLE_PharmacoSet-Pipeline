from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()
from pathlib import Path


expression = config["molecularProfiles"]["expression"]

rule downloadExpression:
    input:
        genes_rsem = HTTP.remote(expression["file_rsem-genes_tpm"]["url"]),
        transcripts_rsem = HTTP.remote(expression["file_rsem-transcripts_tpm"]["url"]),
    output:
        genes_tpm=rawdata / "expression/CCLE_RNAseq_rsem_genes_tpm_20180929.txt",
        transcripts_tpm=rawdata / "expression/CCLE_RNAseq_rsem_transcripts_tpm_20180929.txt",
    shell:
        "gunzip {input.genes_rsem} -c > {output.genes_tpm} && gunzip {input.transcripts_rsem} -c > {output.transcripts_tpm}"

rule downloadMutation:
    input:
        oncomapAssay = HTTP.remote(config["molecularProfiles"]["mutation"]["file_oncomapAssay"]["url"]),
        oncomap = HTTP.remote(config["molecularProfiles"]["mutation"]["file_oncomap"]["url"]),
    output:
        oncomapAssay=rawdata / "mutation/CCLE_Oncomap3_Assays_2012-04-09.csv",
        oncomap=rawdata / "mutation/CCLE_Oncomap3_2012-04-09.maf",
    shell:
        "mv {input.oncomapAssay} {output.oncomapAssay} && mv {input.oncomap} {output.oncomap}"

rule downloadMethylation:
    input:
        methylation = HTTP.remote(config["molecularProfiles"]["methylation"]["RBBS_TSS1kb"]["url"]),
    output:
        methylation=rawdata / "methylation/CCLE_RRBS_TSS1kb_20181022.txt.gz",
    shell:
        "mv {input.methylation} {output.methylation}"


rule downloadCNV:
    input:
        cnv = HTTP.remote(config["molecularProfiles"]["cnv"]["copynumber_byGene"]["url"]),
    output:
        cnv=rawdata / "cnv/CCLE_copynumber_byGene_2013-12-03.txt",
    shell:
        "gunzip {input.cnv} -c > {output.cnv}"

SNPArrays = config["molecularProfiles"]["cnv"]["SNParrays"]
import shutil, os
rule downloadSNPArrays:
    input:
        arrays = [HTTP.remote(SNPArrays[url]) for url in SNPArrays.keys() if url.startswith("url")]
    output:
        arrays=[rawdata / "cnv/snpArrays/{}".format(Path(SNPArrays[url]).name) for url in SNPArrays.keys() if url.startswith("url")]
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