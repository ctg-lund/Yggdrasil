#!/usr/bin/env nextflow
// Objective:
// 1. receive a raw data directory path from cron job
// 2. symlink rawdata to /shared/Jobs/JobID/raw
// 3. parse samplesheet...csv for metadata and samplesheet
// 4. call the nf-core demultiplex pipeline with the samplesheet
// 5. based on parameter in metadata, start the correct pipeline

// Enable DSL2 functionality
nextflow.enable.dsl = 2




// Define parameters
params.project_root = "/projects/fs1/shared/Test_Jobs"
params.nfcore_demultiplex = "/projects/fs1/shared/pipelines/Demux/nf-core-demultiplex-1.0.0/workflow/"
params.rawdata = "/projects/fs1/shared/Test_Data/TEST"
params.projectids = "comma,separated,list,in,ctg,config"
params.samplesheets = "comma,separated,list,in,ctg,config"
params.pipeline = 'example1,example2,example3'
params.pipeline_root = "/projects/fs1/shared/pipelines/"
params.flowcell = "AAA000"

// Define workflow
workflow {
    // get input raw data directory (from cli)
    // --rawdata /path/to/rawdata
    ch_project_dir = Channel.from(params.projectids.split(','))
    ch_samplesheet = Channel.from(params.samplesheets.split(','))
    PREPARE_JOB_DIR(ch_project_dir)
    // need to create a channel with rawdata path and samplesheets
    DEMULTIPLEX(PREPARE_JOB_DIR.out, ch_samplesheet)
    PROCESS(DEMULTIPLEX.out)
    // DELIVERY waiting with this until all is tested
}


process PREPARE_JOB_DIR {
    publishDir "${params.project_root}/", mode: 'copyNoFollow'
    input:
    val projectid
    output:
    path "${projectid}"
    path "${projectid}/${params.flowcell}"
    shell:
    """
    mkdir -p !{projectid}
    ln -s !{params.rawdata} !{projectid}/!{params.flowcell}
    """
}

process DEMULTIPLEX {
    publishDir "${params.project_root}/${projectid}", mode: 'copy'
    input:
    path projectid
    path raw
    val samplesheet
    output:
    path projectid
    path "0_demux/out.txt"
    shell:
    """
    mkdir -p 0_demux/
    echo "nextflow run !{params.nfcore_demultiplex} \
--input !{params.rawdata}/!{samplesheet} \
--outdir 0_demux -profile singularity \
--demultiplexer 'bcl2fastq'" > 0_demux/out.txt
    """
}

// here it will be important that params.pipeline
// corresponds to one of the pipelines in params.pipeline_root
process PROCESS {
    // dummy
    publishDir "${params.project_root}/${projectid}", mode: 'copy'
    input:
    path projectid
    path demux_out
    output:
    path "*"
    shell:
    """
    mkdir -p 1_process
    echo "nextflow run ${params.pipeline_root}/${params.pipeline} \
--input ${projectid}/0_demux \
--outdir 1_process -profile singularity" > 1_process/nf_run.txt
    """
}
