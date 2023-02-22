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
params.templates = "/projects/fs1/shared/Yggdrasil/templates"
// FAKE PARAMS
params.rawdata = "/projects/fs1/shared/Test_Data/TEST"


// Define workflow
workflow {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))  
    ch_raw = Channel.fromPath(params.rawdata)
    (ch_proj_id_file, ch_flowcell_file, ch_pipeline_file, ch_samplesheet) = GET_PARAMS(ch_raw) 
    DEMULTIPLEX(ch_samplesheet)
    PUBLISH(DEMULTIPLEX.out)
}

process GET_PARAMS {
    input:
    path raw    
    output:
    path "projectids.txt"
    path "flowcell.txt"
    path "pipeline.txt"
    path "SampleSheet.csv"
    shell:
    """
python !{params.templates}/get_params.py !{raw} 
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
--bcl-input-directory ${params.rawdata} \
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
    

