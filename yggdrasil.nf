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
    GET_PARAMS(ch_raw) | GENERATE_SAMPLESHEET | DEMULTIPLEX
    PUBLISH(ch_projectids, DEMULTIPLEX.out)
}

process GET_PARAMS {
    input:
    path raw    
    output:
    path raw 
    path "projectids.txt"
    path "flowcell.txt"
    path "pipeline.txt"
    path "SampleSheet.csv"
    script:
    """ 
    #!usr/bin/env python
    import os
    import pathlib
    import re

    # find the samplesheet
    raw = pathlib.Path('${raw}')
    # grab the first one, shouldn't be more lying around
    samplesheet = list(raw.glob('CTG_*.csv'))[0]  
    # first open file
    with open(samplesheet, 'r') as f:
        # read the samplesheet into string
        ss = f.read()
    # use regex to capture [BCLConvert_Data]()[*]
    pattern = re.compile(r'.*BCLConvert_Data\]\n(.*?)\n\[', re.DOTALL)
    data = pattern.findall(ss)[0]   
    # find the Sample_Project column and extract unique values
    my_split = data.split('\n')
    # search in the first item
    for i, item in enumerate(my_split[0].split(',')):
        if item == 'Sample_Project':
            # get the index of the column
            col = i
    # make set with unique values in the column
    projectids = set([item.split(',')[col] for item in my_split[1:]])
    # write to file
    with open('projectids.txt', 'w') as f:
        f.write('\n'.join(projectids))
    # find the flowcell
    # the flowcell is printed by the sequencer
    # to RunParameters.xml
    with open(raw / 'RunParameters.xml', 'r') as f:
        rp = f.read()
    # use regex to capture <Flowcell>(.*)</Flowcell>
    pattern = re.compile(r'.*<Flowcell>(.*)</Flowcell>.*', re.DOTALL)
    flowcell = pattern.findall(rp)[0]
    # write to file
    with open('flowcell.txt', 'w') as f:
        f.write(flowcell)
    # find the pipeline to run
    # look for the pipeline name in the samplesheet
    # under [Yggdrasil_Settings]
    pattern = re.compile(r'.*Yggdrasil_Settings\]\n.*Pipeline,(\w),.*', re.DOTALL)
    pipeline = pattern.findall(ss)[0]
    # write to file
    with open('pipeline.txt', 'w') as f:
        f.write(pipeline)
    # also write out the content of samplesheet
    with open('SampleSheet.csv', 'w') as f:
        f.write(ss)
    """
}

process GENERATE_SAMPLESHEET {
    input:
    path raw
    path projectids
    path flowcell
    path pipeline
    path samplesheet
    output:
    path "demux_samplesheet.csv"
    shell:
    id = raw.name
    """
    # lane nr is optional!
    echo "id,samplesheet,lane,flowcell" > demux_samplesheet.csv
    echo "!{id},!{samplesheet},,!{raw}" >> demux_samplesheet.csv
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
    

