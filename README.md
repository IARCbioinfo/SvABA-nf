# svaba-nf
## Structural variant calling 

[![CircleCI](https://circleci.com/gh/IARCbioinfo/svaba-nf.svg?style=svg)](https://circleci.com/gh/IARCbioinfo/svaba-nf)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://hub.docker.com/r/iarcbioinfo/svaba-nf/)
[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/1818)

![Image SvABA](https://github.com/IARCbioinfo/svaba-nf/blob/master/svaba.png)

## Description ##

Perform structural variant calling with SvABA.

## Dependencies ## 

1. This pipeline is based on [nextflow](https://www.nextflow.io). As we have several nextflow pipelines, we have centralized the common information in the [IARC-nf](https://github.com/IARCbioinfo/IARC-nf) repository. Please read it carefully as it contains essential information for the installation, basic usage and configuration of nextflow and our pipelines.
2. SvABA: see official installation [here](https://github.com/walaj/svaba). 
## Input ## 

**Name**          | **Description**
----------------- | ---------------
--input_folder    |  Folder containing normal (.normal.bam) and tumor (.tumor.bam) BAM files
--ref_file        |  Path to reference fasta file. It should be indexed
--correspondance  |  A correspondance file, with columns `ID`, `tumor`, and `normal` specifying the name of the sample and the tumor/normal file names in the input folder
--dbsnp_file      |  DbSNP file, available [here](https://data.broadinstitute.org/snowman/dbsnp_indel.vcf)
--output_folder   |  Path to output folder

## Parameters ## 

### Optional ###
**Name**          | **Example value** | **Description**
------------------| ------------------| ------------------
--svaba           | /usr/bin/svaba    | Path to SvABA installation directory

### Flags ###

Flags are special parameters without value.

**Name**      | **Description**
------------- | -------------
--help        | Display help

## Download test data set ##

`git clone https://github.com/iarcbioinfo/data_test`

## Usage ##

`nextflow run SvABA.nf  --input_folder  path/to/input/ --svaba path/to/svaba/ --ref_file path/to/ref/ --dbsnp_file path/to/dbsnp_indel.vcf --output_folder /path/to/output` 

## Output ##

**Name**                   | **Description**
-------------------------- | --------------------------
txts (.bps.txt.gz)         |  Raw, unfiltered variants
BAMs (.contigs.bam)        |  Unsorted assembly contigs as aligned to the reference with BWA-MEM
Logs (.log)                |  Run-time information
txts (.discordants.txt.gz) |  Discordant reads identified with 2+ reads
VCFs (.vcf )               |  VCF of rearrangements and indels

