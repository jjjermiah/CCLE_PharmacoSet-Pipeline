from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()
from pathlib import Path

metadataFiles = config["metadata"]

rule downloadSampleAnnotation:
    input:
        sampleAnnotation = HTTP.remote(metadataFiles["sampleAnnotation"])
    output:
        sampleAnnotation = metadata / "sampleAnnotation.txt"
    shell:
        "wget -O {output} {input}"


rule downloadTreatmentAnnotation:
    input:
        treatmentAnnotation = HTTP.remote(metadataFiles["treatmentAnnotation"])
    output:
        treatmentAnnotation = metadata / "treatmentAnnotation.csv"
    shell:
        "wget -O {output} {input}"