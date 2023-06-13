process INTEROP_QC {
    tag "$raw"
    input:
    path(raw)

    output:
    path("interops_qc.html"), emit: interop_qc

    shell:
    """
    #Interops qc script
    touch qc/interop/interops_qc.html
    """ 
    stub:
    """
    mkdir -p qc/interop
    touch qc/interop/interops_qc.html
    """
}