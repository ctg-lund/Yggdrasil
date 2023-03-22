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
/*    INTEROP_QC (
        ch_raw
    )
*/
    DEMULTIPLEX(
        GET_PARAMS.out.demux_samplesheet,
        ch_raw
    )
    MOVE_FASTQS(
        DEMULTIPLEX.out
    )

}


process INTEROP_QC {

    //The QC of the Illumina run will be processed through multiqc
    // At the moment not part of the pipeline

    input:
    path(raw)

    output:
    path("interops_qc.html"), emit: interop_qc

    shell:
    """
    #Interops qc script
    """ 
}

// doing it this way produces output dirs by project id
// meaning we get that info and separation of output
// for free
// CTG_SampleSheet.csv

process DEMULTIPLEX {
    input:
    path(demux_samplesheet)
    path(raw)

    output:
    path("2*_*"), emit: demux_out

    shell:
    """
    bcl-convert \
    --bcl-input-directory ${raw} \
    --output-directory . \
    --force \
    --sample-sheet ${demux_samplesheet} \
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
    

