# this is a simple python script to run snakemake using the snakemake python API

from snakemake import snakemake
import os
import sys
import argparse
import subprocess
import re

def main(dryrun):
    print("Running snakemake")
    snakemake(
        snakefile="workflow/Snakefile",
        cores=10,
        dryrun=dryrun
    )


if __name__ == "__main__":

    parseArgs = argparse.ArgumentParser(description='Run snakemake')
    
    parseArgs.add_argument('dag', help='Output DAG')
    parseArgs.add_argument('--dryrun', '-n', action='store_true', help='Dry run')
    args = parseArgs.parse_args()
    if(args.dag):
        snakemake(
            snakefile="workflow/Snakefile",
            cores=10,
            printdag=True)
        sys.exit(0)

    
    dryrun = args.dryrun if hasattr(args, 'dryrun') else False

    main(dryrun)
