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
params.input_csv = "${rawdata}/samplesheet.csv"
params.rawdata = "set this from cli"

// Define workflow
workflow {
    // get input raw data directory (from cli)
    // --rawdata /path/to/rawdata
    ch_rawdata = Channel.fromPath(params.rawdata)
    PREPARE_JOB_DIR(ch_rawdata) 
    PARSE_METADATA(PREPARE_JOB_DIR.out.JOB_IDs)
    CALL_DEMULTIPLEX(PARSE_METADATA.out.samplesheets)
    CALL_PIPELINE(PARSE_METADATA.out.metadata)
    
}

// take raw data path and return a list of job ids
// also create a directory for each job id
process PREPARE_JOB_DIR {
    publishDir "${params.proj_root}/", mode: 'move'
    // input
    input:
    path(rawdata)
    // output list of job ids
    output:
    path("JOB_IDs.txt")

    // script
    script:
    """
    #!/bin/python3
    import re
    from pathlib import Path
    pattern = re.compile(r"(\d{4}_\d{1,3})")
    my_csv = open("${params.input_csv}", "r")
    # each file can contain several comma separated JOB_IDs
    # we want all of them in a set to avoid duplicates
    JOB_IDs = set()
    # solution with regex
    for line in my_csv:
        JOB_IDs.update(lambda x: for x in pattern.findall(line)[1:])
    
    # for each job id in the set, create a directory
    # and symlink the rawdata to it
    # it may already exist
    for JOB_ID in JOB_IDs:
        Path(f"${params.project_root}/\${JOB_ID}").mkdir(parents=True, exist_ok=True)
        Path(f"${params.project_root}/\${JOB_ID}/raw").symlink_to("${rawdata}")
    # print all job ids to file
    with open("JOB_IDs.txt", "w") as f:
        for JOB_ID in JOB_IDs:
            f.write(f"\${JOB_ID}
    """
}

// next step is to parse the samplesheet.csv
// and create a samplesheet for each job id
// and isolate the metadata for each job id
process PARSE_METADATA {
    // input
    input:
    path(JOB_IDs)
    // output
    output:
    path("metadata.txt")
    path("samplesheets/*")

    // script
    script:
    """
    #!/bin/python3
    import re
    from pathlib import Path
    # read in the job ids
    with open("${JOB_IDs}", "r") as f:
        JOB_IDs = f.read().splitlines()
    # read in the samplesheet
    my_csv = open("${params.input_csv}", "r")
    # create a dictionary for each job id
    # and a list of samplesheets
    metadata = {}
    samplesheets = []
    # PLACEHOLDER
    """
}

// next step is to call the nf-core demultiplex pipeline
// with the samplesheet for each job id
process CALL_DEMULTIPLEX {
    // input
    input:
    path(samplesheets)
    // output
    output:
    path("demultiplex/*")

    // script
    script:
    """
    #!/bin/bash
    # call the nf-core demultiplex pipeline
    # with the samplesheet for each job id
    for samplesheet in ${samplesheets}:
        JOB_ID = $(basename ${samplesheet} | cut -d'.' -f1)
        nextflow run nf-core/demultiplex \\
            -r 2.0.0 \\
            -profile docker \\
            --input ${samplesheet} \\
            --outdir ${params.project_root}/\${JOB_ID}/demultiplex
    """
}

// next step is to call the correct pipeline
// based on the metadata
process CALL_PIPELINE {
    // input
    input:
    path(metadata)
    // output
    output:
    path("pipeline/*")

    // script
    script:
    """
    #!/bin/bash
    # call the correct pipeline
    # based on the metadata
    for JOB_ID in ${metadata}:
        if [ ${metadata[JOB_ID]["run_type"]} == "WGS" ]; then
            nextflow run nf-core/wgs \\
                -r 2.0.0 \\
                -profile docker \\
                --input ${params.project_root}/\${JOB_ID}/demultiplex/fastq \\
                --outdir ${params.project_root}/\${JOB_ID}/pipeline
        elif [ ${metadata[JOB_ID]["run_type"]} == "WES" ]; then
            nextflow run nf-core/wes \\
                -r 2.0.0 \\
                -profile docker \\
                --input ${params.project_root}/\${JOB_ID}/demultiplex/fastq \\
                --outdir ${params.project_root}/\${JOB_ID}/pipeline
        elif [ ${metadata[JOB_ID]["run_type"]} == "RNA-Seq" ]; then
            nextflow run nf-core/rnaseq \\
                -r 2.0.0 \\
                -profile docker \\
                --input ${params.project_root}/\${JOB_ID}/demultiplex/fastq \\
                --outdir ${params.project_root}/\${JOB_ID}/pipeline
        fi
    """
}