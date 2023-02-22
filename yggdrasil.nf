#!/usr/bin/env nextflow
// Objective:
// 1. get raw data and projectids from cron job

// Enable DSL2 functionality
nextflow.enable.dsl = 2




// Define parameters
params.project_root = "/projects/fs1/shared/Test_Jobs"
params.pipeline_root = "/projects/fs1/shared/Test_Jobs"
params.nfcore_demux = "${params.pipeline_root}/nf-core-demultiplex-1.1.0"
params.singularity_images = "${params.nfcore_demux}/singularity-images"
params.bclconvert_singularity = "${params.singularity_images}/nfcore-bclconvert-4.0.3.img"
// FAKE PARAMS
params.rawdata = "/projects/fs1/shared/Test_Data/TEST"


// Define workflow
workflow {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))  
    ch_raw = Channel.fromPath(params.rawdata)
    GET_PARAMS(ch_raw) | DEMULTIPLEX
    PUBLISH(DEMULTIPLEX.out)
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
    path samplesheet
    shell:
    id = raw.name
    """
    # lane nr is optional!
    # echo "id,samplesheet,lane,flowcell" > demux_samplesheet.csv
    # echo "!{id},!{samplesheet},,!{raw}" >> demux_samplesheet.csv
    # fuck nf core, we do it our way

    """
}

// doing it this way produces output dirs by project id
// meaning we get that info and separation of output
// for free
process DEMULTIPLEX {
    input:
    path demux_samplesheet
    output:
    path "*"
    shell:
    """
    singularity run --bind /projects/fs1 \
    !{params.bclconvert_singularity} \
    bcl-convert \
    --bcl-input-directory !{params.raw}\
    --output-directory . \
    --force \
    --sample-sheet !{demux_samplesheet} \
    --bcl-sampleproject-subdirectories true \
    --strict-mode true
    """
}

process PUBLISH {
publishDir "${params.project_root}", mode: 'move'  

    input:
    path pid
    output:
    path "*"
    shell:
    """
    echo moving shit
    """ 
}
    

