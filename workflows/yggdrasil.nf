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

// Including all modules
include { INTEROP_QC } from '../modules/interop/main.nf'
include { BCLCONVERT } from '../modules/bclconvert/main.nf'
include { FASTQC } from '../modules/fastqc/main.nf'
include { PUBLISH } from '../modules/publish/main.nf'


// Define workflow
workflow {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))

    ch_raw = Channel.fromPath(params.rawdata)
    INTEROP_QC (
        ch_raw
    )
    BCLCONVERT(
        ch_samplesheet,
        ch_raw
    )
    // the following channel formation needs to be tested
    ch_projids = Channel
        .fromPath(BCLCONVERT.demux_out, type: 'dir')
        .map { [it.name, it ] }
    FASTQC(
        ch_projids
    ).out.set {ch_all_proj}
    PUBLISH(
        ch_all_proj
    )
}
