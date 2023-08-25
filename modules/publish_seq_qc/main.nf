//  ${ncbi_annotation.baseName} to get the basename of the raw_data and then we could get the flowcell id from this bash variable

process PUBLISH_SEQ_QC {
    tag "${proj}"
    publishDir "${params.publish_dir}/${proj}_delivery/0_fastq/", mode: 'copy', pattern: "${proj}_delivery/0_fastq/*"
    publishDir "${params.publish_dir}/${proj}_delivery/1_qc/", mode: 'copy', pattern: "${proj}_delivery/1_qc/*"

    input:
    path(raw)
    tuple val(proj), path(demux_dir), path(qc_dir)

    output:
    path("${proj}_delivery/*")
    
    shell:
    """
    fc=\$(echo ${raw.baseName} | cut -f 4 -d '_')
    mkdir -p ${proj}_delivery/0_fastq/"\${fc}"
    mkdir -p ${proj}_delivery/1_qc/"\${fc}"

    cp -r ${demux_dir}/*gz ${proj}_delivery/0_fastq/"\${fc}"/
    cp -r ${qc_dir}/* ${proj}_delivery/1_qc/"\${fc}"/
    """ 
}