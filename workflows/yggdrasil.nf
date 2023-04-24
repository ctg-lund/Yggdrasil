#!/usr/bin/env nextflow
// Objective:
// 1. get raw data and projectids from cron job

// Enable DSL2 functionality
nextflow.enable.dsl = 2

// manual or automatic samplesheet
if (params.samplesheet) {
    ch_samplesheet = Channel.fromPath("${params.samplesheet}", checkIfExists: true)
} else { 
    ch_samplesheet = Channel.fromPath("${params.rawdata}/CTG_SampleSheet.csv", checkIfExists: true)
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

    ch_raw = Channel.fromPath(params.rawdata)
    //INTEROP_QC (
    //    ch_raw
    //)
    BCLCONVERT(
        ch_samplesheet,
        ch_raw
    )
    ch_samplesheet.view()
    ch_raw.view()
    /*
    // the following channel formation needs to be tested
    ch_projids = Channel
        .fromPath(BCLCONVERT.out.demux_out, type: 'dir')
        .map { file -> tuple(file.getBaseName(), file) } // This creates tuple of name of the project directory and project demux path
    FASTQC(
        ch_projids
    )

    MULTIQC(
        FASTQC.out.collect()
    ).out.set {ch_all_proj}
    PUBLISH_SEQ_QC(
        ch_raw,
        ch_all_proj
    )

    //Example for DRAGEN
    if ("${params.dragen}") {
        DRAGEN(ch_projids)
    }
    */
}
