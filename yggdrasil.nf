#!/usr/bin/env nextflow
// Objective:
// 1. receive a project directory with raw data symlinked

// Enable DSL2 functionality
nextflow.enable.dsl = 2




// Define parameters
params.project_root = "/projects/fs1/shared/Test_Jobs"
params.pipeline_root = "/projects/fs1/shared/pipelines/"
params.nfcore_demultiplex = "/projects/fs1/shared/pipelines/Demux/nf-core-demultiplex-1.0.0/workflow/"
params.rawdata = "/projects/fs1/shared/Test_Data/TEST"
//params.projectids = "comma,separated,list,in,ctg,config"
//params.samplesheets = "comma,separated,list,in,ctg,config"
//params.pipeline = 'example1,example2,example3'
//params.flowcell = "AAA000"

// Define workflow
workflow {
    // get projectid from cron python script
    ch_projectids = Channel.fromPath(params.projectid)
    ch_raw = Channel.fromPath(params.rawdata)
    GENERATE_SAMPLESHEET(ch_raw)
    DEMULTIPLEX(GENERATE_SAMPLESHEET.out)
}

process GENERATE_SAMPLESHEET {
    input:
    path raw
    output:
    path demux_samplesheet.csv
    shell:
    """
    echo "id,samplesheet,lane,flowcell" > demux_samplesheet.csv
    echo !{raw},!{raw}/SampleSheet.csv,1,!{params.flowcell} >> demux_samplesheet.csv
    """
}

process DEMULTIPLEX {
    input:
    path raw
    output:
    val projectids
    path "0_demux/out.txt"
    shell:
    """

    echo "nextflow run !{params.nfcore_demultiplex} \
--input !{raw}/!{samplesheet} \
--outdir 0_demux -profile singularity \
--demultiplexer 'bcl2fastq'" > 0_demux/out.txt
    """
}


