#!/bin/bash

# this script will setup the CCLE project
# it assumes that you already have conda installed

# check if mamba is installed
# if ! command -v mamba &> /dev/null
# then
#     conda env create -f workflow/envs/CCLE_snakemake.yaml
# else
#     mamba env create -f workflow/envs/CCLE_snakemake.yaml
# fi
# conda init bash
# conda activate CCLE_snakemake


Rscript -e 'remotes::install_github("bhklab/AnnotationGx", build_manual=FALSE, build_vignettes=FALSE)'
