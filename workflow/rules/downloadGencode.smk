from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider

HTTP = HTTPRemoteProvider()


# HOW TO USE
# in a rule, set 
# input:
#   gencodeAnnotation = gencodeAnnotation(dirPath, ref_build, gencode_ver, species="human")
# and this code will handle the rest of the pathing

# IMPORTANT: Gencode v22 and below do not have GRCh37 mappings, any downloaded files will be whatever 
# is available, regardless of how the rule is written

def gencodeAnnotation(dirPath, ref_build, gencode_ver, species="human"):
    return f"{dirPath}/{species}/{ref_build}/release-{gencode_ver}/GENCODE-annotation.gtf.gz"

def gencodeGenome(dirPath, ref_build, gencode_ver, species="human"):
    return f"{dirPath}/{species}/{ref_build}/release-{gencode_ver}/GENCODE-genome.fa.gz"

def gencodeTranscriptome(dirPath, ref_build, gencode_ver, species="human"):
    return f"{dirPath}/{species}/{ref_build}/release-{gencode_ver}/GENCODE-transcriptome.fa.gz"

rule downloadAllGencode:
    input:
        expand(
            "{dirPath}/{species}/{ref_build}/release-{gencode_ver}/GENCODE-{TYPE}.gz",
            TYPE = ["annotation.gtf", "genome.fa", "transcriptome.fa"],
            dirPath = "references",
            species = "human",
            ref_build = ["GRCh37", "GRCh38"],
            gencode_ver = range(19,23),
        ),


######## GENCODE ########
def get_gencode_annotation(ref_build, gencode_release):
    if int(gencode_release) > 22:
        if ref_build == "GRCh37":
            ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/GRCh37_mapping/gencode.v{gencode_release}lift37.annotation.gtf.gz"
        else:
            ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/gencode.v{gencode_release}.annotation.gtf.gz" 
    else:
        if ref_build == "GRCh37":
            print("GENCODE release 22 and below do not have GRCh37 mappings")
        ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/gencode.v{gencode_release}.annotation.gtf.gz"
    return "http://" + ftp


rule getGENCODEannotation:
    output:
        gencode_annotation_file="{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/GENCODE-annotation.gtf.gz",
    threads:
        1
    params:
       url = lambda wc: get_gencode_annotation(ref_build = wc.ref_build, gencode_release = wc.gencode_release)
    log:
        "logs/{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/gencode_annotation_download.log"
    shell:
        "wget -O {output.gencode_annotation_file} {params.url} > {log} 2>&1"


def get_gencode_genome(ref_build, gencode_release, species="human"):
    if int(gencode_release) > 22:
        if ref_build == "GRCh37":
            ftp_genome = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/GRCh37_mapping/GRCh37.primary_assembly.genome.fa.gz"
        else:
            ftp_genome = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/GRCh38.primary_assembly.genome.fa.gz"
    else:
        if ref_build == "GRCh37":
            print("GENCODE release 22 and below do not have GRCh37 mappings")
        if int(gencode_release) ==19:
            ftp_genome = "http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz"
        elif (int(gencode_release) == 20) or (int(gencode_release) == 21):
            ftp_genome = f"http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/GRCh38.genome.fa.gz"
        elif int(gencode_release) == 22:
            ftp_genome = "http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_22/GRCh38.primary_assembly.genome.fa.gz"

    return "http://" + ftp_genome


rule getGENCODEgenome:
    output:
        gencode_genome_file="{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/GENCODE-genome.fa.gz",
    threads:
        1
    params:
        url = lambda wc: get_gencode_genome(ref_build = wc.ref_build, gencode_release = wc.gencode_release)
    log:
        "logs/{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/gencode_genome_download.log"
    shell:
        "wget -O {output.gencode_genome_file} {params.url} > {log} 2>&1"

def get_gencode_transcriptome(ref_build, gencode_release):
    if int(gencode_release) > 22:
        if ref_build == "GRCh37":
            ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/GRCh37_mapping/gencode.v{gencode_release}lift37.transcripts.fa.gz"
        else:
            ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/gencode.v{gencode_release}.transcripts.fa.gz"
    else:
        if ref_build == "GRCh37":
            print("GENCODE release 22 and below do not have GRCh37 mappings")
        ftp = f"ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_{gencode_release}/gencode.v{gencode_release}.pc_transcripts.fa.gz"
    return "http://" + ftp


rule getGENCODEtranscriptome:
    output:
        gencode_genome_file="{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/GENCODE-transcriptome.fa.gz",
    threads:
        1
    params:
        url = lambda wc: get_gencode_transcriptome(ref_build = wc.ref_build, gencode_release = wc.gencode_release)
    log:
        "logs/{ANY_PATH}/{species}/{ref_build}/release-{gencode_release}/gencode_transcriptome_download.log"
    shell:
        "wget -O {output.gencode_genome_file} {params.url} > {log} 2>&1"
        
