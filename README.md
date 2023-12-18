# This is the repository for the CCLE pipeline

# So far, the following has been implemented:
![PIPELINE](resources/dag.svg)


# Running the pipeline

### Annotate Metadata 
![METADATA_PIPELINE](resources/metadata_dag.svg)
```bash
# Set your number of cores
NUMCORES=8
snakemake -s workflow/Snakefile --cores $NUMCORES annotateALLMetadata
```

# Data sources used:

NOTE: see `workflow/config/config.yaml` for the full list of data sources used
![Alt text](resources/image.png)