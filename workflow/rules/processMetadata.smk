_scripts = ".." / scripts

rule annotateALLMetadata:
    input:
        annotatedSampleData = procdata / "metadata/annotatedSampleData.qs",
        annotatedTreatmentData = procdata / "metadata/annotatedTreatmentData.qs",

rule annotateTreatmentData:
    input:
        preprocessedMetadata = procdata / "metadata/preprocessedMetadata.qs"
    output:
        annotatedTreatmentData = procdata / "metadata/annotatedTreatmentData.qs"
    log:
        "logs/metadata/annotateTreatmentData.log"
    threads:
        10
    script:
        _scripts / "metadata/annotateTreatmentData.R"


rule annotateSampleData:
    input:
        mappedSampleData = procdata / "metadata/mappedSampleData.qs"
    output:
        annotatedSampleData = procdata / "metadata/annotatedSampleData.qs"
    log:
        "logs/metadata/annotateSampleData.log"
    threads:
        10
    retries: 
        3
    script:
        _scripts / "metadata/annotateSampleData.R"

rule mapSampleNamesToCellosaurusAccessionID:
    input:
        preprocessedMetadata = procdata / "metadata/preprocessedMetadata.qs"
    output:
        mappedSampleData = procdata / "metadata/mappedSampleData.qs"
    log:
        "logs/metadata/mapSampleNamesToCellosaurusAccessionID.log"
    threads:
        10
    script:
        _scripts / "metadata/mapSampleNamesToCellosaurusAccessionID.R"

rule preprocessCellosaurusData:
    output:
        cellosaurusObject = procdata / "metadata/cellosaurus.qs",
    conda:
        "envs/annotationgx.yaml",
    log:
        "logs/metadata/preprocessCellosaurusData.log"
    shell:
        """
        Rscript -e \
        'qs::qsave(\
            AnnotationGx::getCompleteCellosaurusObject(), 
            file = "{output.cellosaurusObject}")' \
        > {log} 2>&1
        """

rule preprocessMetadata:
    input:
        sampleAnnotation = metadata / "sampleAnnotation.txt",
        treatmentAnnotation = metadata / "treatmentAnnotation.csv"
    output:
        preprocessedMetadata = procdata / "metadata/preprocessedMetadata.qs"
    threads:
        1
    script:
        _scripts / "metadata/preprocessMetadata.R"