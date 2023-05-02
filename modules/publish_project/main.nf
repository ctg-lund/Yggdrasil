process PUBLISH_PROJECT{
    publishDir "${params.outdir}/${project_name}", mode: 'copy'
    input:
    path project_dir
    val project_name
    output:
    path project_dir
    script:
    """
    echo Hippity hoppity, your project is now my property
    """
}