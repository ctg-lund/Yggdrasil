//  ${ncbi_annotation.baseName} to get the basename of the raw_data and then we could get the flowcell id from this bash variable

process PUBLISH_RNASEQ {
    tag "${proj}"
    publishDir "${params.publish_dir}/${proj}_delivery/2_rnaseq/", mode: 'copy', pattern: "${proj}_delivery/2_rnaseq/*"  

    input:
    path(raw)
    tuple val(proj), path(rnaseq_dir)

    output:
    path("${proj}_delivery/*")
    
    shell:
    """
    fc=\$(echo ${raw.baseName} | cut -f 4 -d '_')
    mkdir -p ${proj}_delivery/2_rnaseq/"\${fc}"

    cp -r ${rnaseq_dir}/* ${proj}_delivery/2_rnaseq/"\${fc}"/
    """ 
}