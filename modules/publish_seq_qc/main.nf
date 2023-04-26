//  ${ncbi_annotation.baseName} to get the basename of the raw_data and then we could get the flowcell id from this bash variable

process PUBLISH_SEQ_QC {
    tag "${proj}"
    publishDir "${params.publish_dir}", mode: 'copy'  

    input:
    path(raw)
    tuple val(proj), path(demux_dir), path(qc_dir)

    output:
    path("${proj}_delivery/*")
    
    shell:
    """
    fc=`echo ${raw.baseName} | cut -f 4 -d '_'`
    mkdir -p ${proj}_delivery/"\${fc}"/0_fastq
    mkdir -p ${proj}_delivery/"\${fc}"/1_qc

    cp -r ${demux_dir}/* ${proj}_delivery/"\${fc}"/0_fastq/
    cp -r ${qc_dir}/* ${proj}_delivery/"\${fc}"/1_qc/
    """ 
}