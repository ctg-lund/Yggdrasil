#!/usr/bin/env nextflow
// Objective:
// 1. get raw data and projectids from cron job

// Enable DSL2 functionality
nextflow.enable.dsl = 2




// Define parameters
params.project_root = "/projects/fs1/shared/Test_Jobs"
params.pipeline_root = "/projects/fs1/shared/"
//params.nfcore_demultiplex = "/projects/fs1/shared/pipelines/Demux/nf-core-demultiplex-1.0.0/workflow/"
params.rawdata = "/projects/fs1/shared/Test_Data/TEST"
//params.projectids = "comma,separated,list,from,cron"
//params.samplesheets = "comma,separated,list,in,ctg,config"
//params.pipeline = 'example1,example2,example3'
//params.flowcell = "AAA000"

// Define workflow
workflow {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))  
    ch_raw = Channel.fromPath(params.rawdata)
    GET_PARAMS(ch_raw) | GENERATE_SAMPLESHEET | DEMULTIPLEX
    PUBLISH(ch_projectids, DEMULTIPLEX.out)
}

process GET_PARAMS {
    input:
    path raw    
    output:
    path raw 
    path "projectids.txt"
    path "flowcell.txt"
    path "pipeline.txt"
    path "SampleSheet.csv"
    script: 
    template = "get_params.py"
}

process GENERATE_SAMPLESHEET {
    input:
    path raw
    path projectids
    path flowcell
    path pipeline
    path samplesheet
    output:
    path "demux_samplesheet.csv"
    shell:
    id = raw.name
    """
    # lane nr is optional!
    echo "id,samplesheet,lane,flowcell" > demux_samplesheet.csv
    echo "!{id},!{samplesheet},,!{raw}" >> demux_samplesheet.csv
    """
}

process DEMULTIPLEX {
    input:
    path demux_samplesheet
    output:
    path "0_demux/*"
    shell:
    """
    mkdir -p 0_demux
    echo "nextflow run !{params.nfcore_demultiplex} \
--input !{demux_samplesheet} \
--outdir 0_demux -profile singularity \
--demultiplexer 'bclconvert'" > 0_demux/out.txt
    """
}

process PUBLISH {
publishDir "${params.project_root}", mode: 'move'  

    input:
    val pid
    path demux
    output:
    path "${pid}/${demux}/*"
    shell:
    """
    mkdir -p !{pid} 
    mv !{demux} !{pid}    
    """ 
}
    

