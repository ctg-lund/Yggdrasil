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
    ch_samplesheet = Channel.fromPath("${params.samplesheet}", checkIfExists: true)
} else { 
    ch_samplesheet = Channel.fromPath("${params.rawdata}/CTG_SampleSheet*.csv", checkIfExists: true)
}

// manual or automatic outdir
if (params.outdir) {
    params.publish_dir = "${params.outdir}"
} else { 
    params.publish_dir = "${params.project_root}" 
}

// Including modules
include { PARSE_SS } from '../modules/parse_ss/main'
include { INTEROP_QC } from '../modules/interop/main'
include { BCL_DELIVERY } from '../modules/bcl_delivery/main'
include { BCLCONVERT } from '../modules/bclconvert/main'
include { FASTQC } from '../modules/fastqc/main'
include { MULTIQC } from '../modules/multiqc/main'
include { PUBLISH_SEQ_QC } from '../modules/publish_seq_qc/main'
include { NFCORE_RNASEQ } from '../modules/nfcore_rnaseq//main'
include { PUBLISH_RNASEQ } from '../modules/publish_rnaseq/main'

// Including subworkflows

include { SINGLE_CELL                   } from '../subworkflows/singleCell'
include { DRAGEN                        } from '../subworkflows/dragen'

// Define workflow
workflow YGGDRASIL {
    // get projectid from cron python script # Lokesh: Let the cron do least possible things! We can get the project ids along with what their respective delivery types are inside Yggdrasil in a python script! 
    // We can keep both the information of the projects and also the delivery-type in the same channel.
    // ch_projectids = Channel.from(params.projectids.split(','))
    PARSE_SS(ch_samplesheet)
    
    ch_raw_delivery = PARSE_SS.out.ss_projIDs
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.Delivery == 'BCL' }
        .map { it -> it.Project_ID }
    
    ch_fastq_delivery = PARSE_SS.out.ss_projIDs
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.Delivery == 'FASTQ' }
        .map { it -> it.Project_ID }
    
    ch_dragen_delivery = PARSE_SS.out.ss_projIDs
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.Delivery == 'DRAGEN' }
        .map { it -> it.Project_ID }
    
    ch_rnaseq_delivery = PARSE_SS.out.ss_projIDs
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.Delivery == 'RNASEQ' }
        .map { it -> it.Project_ID }
    
    ch_methylseq_delivery = PARSE_SS.out.ss_projIDs
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.Delivery == 'METHYLSEQ' }
        .map { it -> it.Project_ID }

    ch_rawdata = Channel.fromPath(params.rawdata)
    //INTEROP_QC (
    //    ch_rawdata
    //)

    // if(!ch_raw_delivery.isEmpty()) {
    //    BCL_DELIVERY(ch_rawdata)
    //}else{

    
    BCLCONVERT(
        ch_samplesheet,
        ch_rawdata
    )
    
    // the following channel formation needs to be tested
    ch_demux = BCLCONVERT.out.demux_out
        .map { file -> tuple(file.getBaseName(), file) } // This creates tuple of name of the project directory and project demux path
    
    FASTQC(
        ch_demux
    )
    
    MULTIQC(
        FASTQC.out.zip
    )

    MULTIQC.out.set {ch_multiqc}
    
    ch_fq_qc = ch_demux
        .join(ch_multiqc)
    
    PUBLISH_SEQ_QC(
        ch_rawdata,
        ch_fq_qc
    )
    
    /** if(!ch_fastq_delivery.isEmpty()) {
    // PUBLISH_PROJECT(
        ch_fastq_delivery
            .join(ch_fq_qc)
    // )
    }**/

    /** if(!ch_rnaseq_delivery.isEmpty()) {
    
    NFCORE_RNASEQ(
        ch_rnaseq_delivery
            .join(ch_fq_qc)
    )
    ch_pub_rna = NFCORE_RNASEQ.out.rnaseq_out
    PUBLISH_RNASEQ(
        ch_rawdata,
        ch_pub_rna
    )
    }**/

    //Example for DRAGEN or RNASEQ
    // These settings will be read from samplesheet
    // create channels for each kind of deliveries
    // like ch_dragen

    /*
    if (!ch_dragen.isEmpty()) {
        DRAGEN(ch_dragen)
    }
    */
    //}
}

workflow.onComplete { 
    if (workflow.success) {
        writetofile("${new Date()} [Information] Yggdrasil workflow completed successfully for ${params.rawdata} #")
    } else {
        writetofile("${new Date()} [Critical] Yggdrasil run ${params.rawdata} failed! Error message: ${workflow.errorMessage} #")
    }
}