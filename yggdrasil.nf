#!/usr/bin/env nextflow
// Objective:
// 1. get raw data and projectids from cron job

// Enable DSL2 functionality
nextflow.enable.dsl = 2




// Define parameters
params.project_root = "/projects/fs1/shared/Test_Jobs"
params.pipeline_root = "/projects/fs1/shared/pipelines/"
//params.nfcore_demultiplex = "/projects/fs1/shared/pipelines/Demux/nf-core-demultiplex-1.0.0/workflow/"
params.rawdata = "/projects/fs1/shared/Test_Data/TEST"
//params.projectids = "comma,separated,list,from,cron"
//params.samplesheets = "comma,separated,list,in,ctg,config"
//params.pipeline = 'example1,example2,example3'
//params.flowcell = "AAA000"

// Define workflow
workflow {
    // get projectid from cron python script
    // ch_projectids = Channel.from(params.projectids.split(','))  
    ch_raw = Channel.fromPath(params.rawdata)
    GENERATE_SAMPLESHEET(ch_raw) | DEMULTIPLEX
    PUBLISH(ch_projectids, DEMULTIPLEX.out)
}

process GET_PARAMS {
    input:
    path raw    
    output: 
    val projectids
    val flowcell
    val pipeline
    shell:
    """ 
   #!usr/bin/env python
    import os
    import pathlib
    import re
    import csv

    # find the samplesheet
    raw = pathlib.Path('!{raw}')
    # grab the first one, shouldn't be more lying around
    samplesheet = list(raw.glob('CTG_*.csv'))[0]  
    # first open file
    with open(samplesheet, 'r') as f:
       # read the samplesheet into string
         ss = f.read()
    # use regex to capture [BCLConvert_Data]()[*]
   pattern = re.compile(r'.*BCLConvert_Data\]\n(.*?)\n\[', re.DOTALL)
   data = pattern.findall(ss)[0]   
    # the data should be treated as csv 
    csv = csv.reader(data.splitlines(), delimiter=',')   
    # find the Sample_Project column and extract unique values

}

process GENERATE_SAMPLESHEET {
    input:
    path raw
    val projectids
    val flowcell
    output:
    path "demux_samplesheet.csv"
    shell:
    """
    # lane nr is optional!
    echo "id,samplesheet,lane,flowcell" > demux_samplesheet.csv
    echo !{raw},!{raw}/SampleSheet.csv,,!{flowcell} >> demux_samplesheet.csv
    """
}

process BCLCONVERT {
    input:
    path demux_samplesheet
    output:
    path "0_demux/*"
    shell:
    """
    mkdir -p 0_demux
    echo "nextflow run !{params.nfcore_demultiplex} \
--input !{demux_samplesheet} \
--outdir 0_demux -profile singularity \
--demultiplexer 'bclconvert'" > 0_demux/out.txt
    """
}

process PUBLISH {
 publishDir "${params.project_root}", mode: 'move'  

    input:
    val pid
    path demux
    output:
    path "{pid}/{demux}/*"
    shell:
    """
    mkdir -p !{pid} 
    mv !{demux} !{pid}    
    """ 
}
    

