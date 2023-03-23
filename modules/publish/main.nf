//  ${ncbi_annotation.baseName} to get the basename of the raw_data and then we could get the flowcell id from this bash variable

process PUBLISH {
publishDir "${params.project_root}", mode: 'copy'  

    input:
    path demux_out
    output:
    path demux_out
    shell:
    """
echo moving !{demux_out}
    """ 
}