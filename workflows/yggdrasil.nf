#!/usr/bin/env nextflow
// Objective:
// 1. get raw data and projectids from cron job

// Enable DSL2 functionality
nextflow.enable.dsl = 2

// Function for appending message to log file
def writetofile(String text) {
    def file = new File(params.nextflow_log)
    def lastline = file.readLines().last()
    def newNumber = lastline.split('#')[1].toInteger() + 1
    file.withWriterAppend { out ->
        out.println(text+newNumber)
    }
}
// manual or automatic samplesheet
if (params.samplesheet) {
    ch_samplesheet = file("${params.samplesheet}", checkIfExists: true)
} else { 
    ch_samplesheet = file("${params.rawdata}/CTG_SampleSheet*.csv", checkIfExists: true)
}

// manual or automatic outdir
if (params.outdir) {
    params.publish_dir = "${params.outdir}"
} else { 
    params.publish_dir = "${params.project_root}" 
}

if (params.dragen) {
    dragen = true
}

// Including modules
include { INTEROP_QC } from '../modules/interop/main'
include { BCLCONVERT } from '../modules/bclconvert/main'
include { FASTQC } from '../modules/fastqc/main'
include { MULTIQC } from '../modules/multiqc/main'
include { PUBLISH_SEQ_QC } from '../modules/publish_seq_qc/main'

// Including subworkflows

include { SINGLE_CELL                   } from '../subworkflows/singleCell'
include { DRAGEN                   } from '../subworkflows/dragen'

// Define workflow
workflow YGGDRASIL {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))

    ch_raw = file(params.rawdata, checkIfExists: true, type: 'directory')
    //INTEROP_QC (
    //    ch_raw
    //)
    
    ch_demux = BCLCONVERT(
        ch_samplesheet,
        ch_raw
    )
    
    
    fastqc_ch = FASTQC(
        ch_demux.map { file -> tuple(file.getBaseName(), file) }
    )
    
    ch_multiqc = MULTIQC(
        fastqc_ch.zip
    )
    
    ch_publish = ch_demux
        .join(ch_multiqc)
    
    PUBLISH_SEQ_QC(
        ch_raw,
        ch_publish
    )

    //Example for DRAGEN
    /*
    if ("${params.dragen}") {
        DRAGEN(ch_demux)
    }
    */
}

workflow.onComplete { 
    if (workflow.success) {
        writetofile("${new Date()} [Information] Yggdrasil workflow completed successfully for ${params.rawdata} #")
    } else {
        writetofile("${new Date()} [Critical] Yggdrasil run ${params.rawdata} failed! Error message: ${workflow.errorMessage} #")
    }
}