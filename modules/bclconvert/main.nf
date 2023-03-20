process BCLCONVERT {
    input:
    path(demux_samplesheet)
    path(raw)

    output:
    path "2*_*"
    shell:
    """
bcl-convert \
--bcl-input-directory !{raw} \
--output-directory . \
--force \
--sample-sheet !{demux_samplesheet} \
--bcl-sampleproject-subdirectories true \
--strict-mode true \
--bcl-only-matched-reads true \
--bcl-num-parallel-tiles 16
    """
}