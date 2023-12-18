_scripts = ".." / scripts

rule preprocessMetadata:
    input:
        sampleAnnotation = metadata / "sampleAnnotation.txt",
        treatmentAnnotation = metadata / "treatmentAnnotation.csv"
    output:
        preprocessedMetadata = procdata / "preprocessedMetadata.qs"
    threads:
        1
    script:
        _scripts / "metadata/preprocessMetadata.R"

rule annotateSampleData:
    input:
        mappedSampleData = procdata / "mappedSampleData.qs"
    output:
        annotatedSampleData = procdata / "annotatedSampleData.qs"
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
        preprocessedMetadata = procdata / "preprocessedMetadata.qs"
    output:
        mappedSampleData = procdata / "mappedSampleData.qs"
    log:
        "logs/metadata/mapSampleNamesToCellosaurusAccessionID.log"
    threads:
        10
    script:
        _scripts / "metadata/mapSampleNamesToCellosaurusAccessionID.R"

rule preprocessCellosaurusData:
    output:
        cellosaurusObject = "metadata/cellosaurus.qs",
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


rule annotateTreatmentData:
    input:
        preprocessedMetadata = procdata / "preprocessedMetadata.qs"
    output:
        annotatedTreatmentData = procdata / "annotatedTreatmentData.qs"
    threads:
        10
    script:
        _scripts / "metadata/annotateTreatmentData.R"