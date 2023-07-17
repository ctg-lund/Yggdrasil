process PARSE_SS {
    input:
    path(samplesheet)

    output:
    path("yggdrasil_projects.csv"), emit: ss_projIDs

    shell:
    """
    parse_samplesheet.py -i ${samplesheet} -o yggdrasil_projects.csv
    """ 
    stub:
    """
    touch yggdrasil_projects.csv
    """
}