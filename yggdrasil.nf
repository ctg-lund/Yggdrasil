#!/usr/bin/env nextflow
// Objective:
// 1. get raw data and projectids from cron job

// Enable DSL2 functionality
nextflow.enable.dsl = 2


// Define workflow
workflow {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))  
    ch_raw = Channel.fromPath(params.rawdata)
    (ch_proj_id_file, ch_flowcell_file, ch_pipeline_file, ch_samplesheet) = GET_PARAMS(ch_raw) 
    DEMULTIPLEX(ch_samplesheet, ch_raw)
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
    path raw
    output:
    path "bcl_out/"
    shell:
    """
bcl-convert \
--bcl-input-directory !{raw} \
--output-directory bcl_out \
--force \
--sample-sheet !{demux_samplesheet} \
--bcl-sampleproject-subdirectories true \
--strict-mode true \
--bcl-only-matched-reads true \
--bcl-num-parallel-tiles 16
    """
}

process PUBLISH {
publishDir "${params.project_root}", mode: 'move'  

    input:
    path demux_out
    output:
    path demux_out
    shell:
    """
echo moving !{demux_out}
    """ 
}
    

