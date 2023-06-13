// doing it this way produces output dirs by project id
// meaning we get that info and separation of output
// for free
// CTG_SampleSheet.csv

process BCLCONVERT {
    tag "$raw"
    input:
    path(demux_samplesheet)
    path(raw)

    output:
    path("2*_*"), emit: demux_out
    

    shell:
    """
    bcl-convert \
    --bcl-input-directory ${raw} \
    --output-directory . \
    --force \
    --sample-sheet ${demux_samplesheet} \
    --bcl-sampleproject-subdirectories true \
    --strict-mode true \
    --bcl-only-matched-reads true \
    --bcl-num-parallel-tiles 16
    """
    stub:
    """
    mkdir -p 23_test
    touch 23_test/test_R1.fastq.gz
    touch 23_test/test_R2.fastq.gz
    """
}