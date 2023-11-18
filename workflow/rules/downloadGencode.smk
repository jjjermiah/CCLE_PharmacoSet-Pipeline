from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider

HTTP = HTTPRemoteProvider()


def gencodeAnnotation(dirPath, ref_build, gencode_ver, species="human"):
    return (
        f"{dirPath}/{species}/{ref_build}/release-{gencode_ver}/GENCODE-annotation.gtf.gz"
    )


######## GENCODE ########
def get_gencode_annotation(wildcards):
    if wildcards.ref_build == "GRCh37":
        if int(wildcards.gencode_release) >= 22:
            ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/GRCh37_mapping/gencode.v{wildcards.gencode_release}lift37.annotation.gtf.gz"
        else:
            ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/gencode.v{wildcards.gencode_release}.annotation.gtf.gz" 
    else:
        ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/gencode.v{wildcards.gencode_release}.annotation.gtf.gz"
    return HTTP.remote(ftp, keep_local=True)


rule getGENCODEannotation:
    input:
        get_gencode_annotation,
    output:
        gencode_annotation_file="{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/GENCODE-annotation.gtf.gz",
        # gencode_annotation_file="references/Gencode_human/gencode.v{gencode_release}.annotation.gtf"
    threads:
        1
    shell:
        "mv {input} {output.gencode_annotation_file}"


def get_gencode_genome(wildcards):
    if wildcards.ref_build == "GRCh37":
        if wildcards.species == "homo_sapiens" or "human" or "Gencode_human":
            ftp_genome = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/GRCh37_mapping/GRCh37.primary_assembly.genome.fa.gz"
    else:
        ftp_genome = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/GRCh38.primary_assembly.genome.fa.gz"
    return HTTP.remote(ftp_genome, keep_local=True)


rule getGENCODEgenome:
    input:
        get_gencode_genome,
    output:
        gencode_genome_file="reference_genomes/GENCODE/{species}/{ref_build}/release-{gencode_release}/genome.fa",
    shell:
        "gzip -d -c {input} > {output}"


def get_gencode_transcriptome(wildcards):
    if wildcards.ref_build == "GRCh37":
        ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/GRCh37_mapping/gencode.v{wildcards.gencode_release}lift37.transcripts.fa.gz"
    else:
        ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{wildcards.gencode_release}/gencode.v{wildcards.gencode_release}.transcripts.fa.gz"
    return HTTP.remote(ftp, keep_local=True)


rule getGENCODEtranscriptome:
    input:
        get_gencode_transcriptome,
    output:
        gencode_genome_file="reference_genomes/GENCODE/{species}/{ref_build}/release-{gencode_release}/transcriptome.fa",
    shell:
        "gzip -d -c {input} > {output}"
