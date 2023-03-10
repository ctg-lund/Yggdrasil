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
    project_dir_fq = DEMULTIPLEX(ch_samplesheet, ch_raw)
    fastqs = MOVE_FASTQS(project_dir_fq)

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
    path "2*_*"
    shell:
    """
bcl-convert \
--bcl-input-directory !{raw} \
--output-directory . \
--force \
--sample-sheet !{demux_samplesheet} \
--bcl-sampleproject-subdirectories true \
--strict-mode true \
--bcl-only-matched-reads true \
--bcl-num-parallel-tiles 16
    """
}

process MOVE_FASTQS {
    input:
    path old_dir
    output:
    path ${old_dir}/0_fastq
    shell:
    """
    mkdir !{old_dir}/0_fastq
    mv !{old_dir}/*.fastq.gz !{old_dir}/0_fastq/
    """
}

process FASTP {
    input:
    path fastqs
    output:
    path "${fastqs}/1_fastqc"
    script:
    """
    #TBD
    """
}

process PUBLISH {
publishDir "${params.project_root}", mode: 'copy'  

    input:
    path demux_out
    output:
    path demux_out
    shell:
    """
echo moving !{demux_out}
    """ 
}
    

