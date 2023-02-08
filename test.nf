// Enable DSL2 functionality
nextflow.enable.dsl = 2

// params
params.proj_root = "$HOME/TEST"
params.Project_IDs = "wrong1,wrong2,wrong3"
params.raw = "$HOME/TEST/"

workflow {
    // get project IDs
    proj_ids = Channel.from(params.Project_IDs.split(','))
    // make project directories and symlink raw data
    SETUP(proj_ids)
}

process SETUP {
    publishDir "${params.proj_root}", mode: 'move'
    input:
    val proj_id
    output:
    path "${proj_id}"
    script:
    """
    mkdir -p ${proj_id}
    ln -s ${params.raw}/${proj_id} ${proj_id}/raw
    """
}
