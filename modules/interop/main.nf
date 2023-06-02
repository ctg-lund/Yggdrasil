process INTEROP_QC {
    input:
    path(raw)

    output:
    path("interop_qc/multiqc_*"), emit: interop_qc

    shell:
    """
    interop_all.sh ${raw}
    """ 
    stub:
    """
    mkdir -p interop_qc/multiqc_FlowCellID
    touch interop_qc/multiqc_FlowCellID/multiqc_interops_qc.html
    """
}