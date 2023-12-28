from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
HTTP = HTTPRemoteProvider()

treatmentResponse = config["treatmentResponse"]

_scripts = ".." / scripts
rule downloadTreatmentResponseData:
    input:
        doseResponse = HTTP.remote(treatmentResponse["doseResponse"]["url"]),
        GNF = HTTP.remote(treatmentResponse["GNF"]["url"]),
    output:
        doseResponse = rawdata / "treatmentResponse/doseResponse.csv",
        GNF = rawdata / "treatmentResponse/GNF.csv",
    shell:
        """
        mkdir -p $(dirname {output.doseResponse}) $(dirname {output.GNF});
        mv {input.doseResponse} {output.doseResponse};
        mv {input.GNF} {output.GNF};
        """

rule createTreatmentResponseExperiment:
    input:
        doseResponse = rawdata / "treatmentResponse/doseResponse.csv",
        GNF = rawdata / "treatmentResponse/GNF.csv",
    output:
        treatmentResponse = results / "data/treatmentResponseExperiment.qs",
    log: 
        "logs/treatmentResponse/processTreatmentResponse.log",
    threads:
        4
    script:
        _scripts / "treatmentResponse/processTreatmentResponse.R"
