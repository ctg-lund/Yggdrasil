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
// just set these three from the cli
params.input_csv = "${rawdata}/samplesheet.csv"
params.rawdata = "set this from cli"
params.jobid = "set this from cli"

// Define workflow
workflow {
    // get input raw data directory (from cli)
    // --rawdata /path/to/rawdata
    ch_rawdata = Channel.fromPath(params.rawdata)
    PREPARE_JOB_DIR(ch_rawdata) 
    CALL_DEMULTIPLEX(PARSE_METADATA)
    CALL_PIPELINE(PARSE_METADATA)
    DELIVER_OUTPUTS()
}

// take raw data path and return a list of job ids
// also create a directory for each job id
// going forward, there will be 1 samplesheet per project
// the samplesheet will be named CTG...SampleSheet.csv
// it is OK to add project id to the file name
// but the file name will never be parsed in our pipelines
// all metadata for a project will be in the CTG_SampleSheet.csv
process PREPARE_JOB_DIR {
    // publish job ids to project root
    publishDir "${params.proj_root}/", mode: 'move'
    // input
    input:
    path(rawdata)
    // output a job directory
    output:
    path(jobid/input_csv)

    // script
    script:
    """
    # job id will be specified in the samplesheet
    mkdir -p ${jobid}
    # symlink raw data to job directory
    ln -s ${rawdata} ${jobid}/raw
    # copy the samplesheet to the job directory
    cp ${params.input_csv} ${jobid}/
    """
}

// next call the demux with samplesheet as samplesheet
// and raw data as run folder
process CALL_DEMULTIPLEX {
    // input
    input:
    path(samplesheet)
    // output
    output:
    path("demux")

    // script
    script:
    """
    # call the demultiplex pipeline
    nextflow run nf-core/demultiplex \\
        --input ${samplesheet} \\
        --outdir demux \\
        --runfolder ${params.rawdata}
    """
}