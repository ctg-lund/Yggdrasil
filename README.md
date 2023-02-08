# Yggdrasil

### one pipeline to rule them all

## Objective summary

### Initialization

* Yggdrasil is a workflow written in nextflow using DSL 2
* It is initiated on LSENS once cron detects a ctg.sync.done file under a raw data directory in ../uploads
* cron will only pass the path to the raw data to Yggdrasil, everything else happens in Yggdrasil

### General Steps of the workflow

1. The CTG_samplesheet...csv is parsed looking for project ids and the raw data is symlinked into project specific directories
2. A list of project IDs is passed onto a parsing process that creates a metadata file and a samplesheet file for each project
3. The raw data and project specific samplesheet is passed into nf-cores demultiplex pipeline
4. Using the project metadata the samplesheet is passed into the correct downstream pipeline


# nextflow config strategy

In this case there is an illumina samplesheet that is supplied with every project and 
the lab doesn't touch this but instead fills in a nextflow config file.

The nextflow config file will have to contain information on all the projects that are included
in a runfolder, and paths to their respective samplesheets.

Ontologically this would be an important distinction as we now no longer have to speak of
nf core samplesheet, illumina samplesheet and ctg samplesheet. The nf-core samplesheet is generated 
and consumed within the workflow itself, while the samplesheet is the ingoing illumina samplesheet that
a customer fills in. All our parameters are now referred to as being in the configuration file, meaning
the per run folder specific nf configuration.