process INTEROP_QC {
    input:
    path(raw)

    output:
    path("interops_qc.html"); emit: interop_qc

    shell:
    """
    #Interops qc script
    """ 
    stub:
    """
    mkdir -p interop/
    touch interop/interops_qc.html
    """
}