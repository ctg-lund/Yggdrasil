process NFCORE_RNASEQ {
	tag "${proj}"
	input:
	tuple val(proj), path(demux_dir)

    output:
    path("nfcore_rnaseq_output"), emit: rnaseq_out

    shell:
    """
    rnaseq_ss.sh ${demux_dir}
    nextflow \ #correct location of the working nextflow binary
        run /home/lokeshwaran/nf-core-rnaseq/workflow/ \ # correct location of the nf-core-rnaseq workflow directory
        -profile ctg \
        -c /home/lokeshwaran/inbox/ctg_rnaseq.config \ #location of ctg_rnaseq.config from Yggdrasil
        --fasta /home/lokeshwaran/nf-core-rnaseq/references/Homo_sapiens.GRCh38.dna_sm.primary_assembly.109.fa.gz \ # location of directory of references created for nf-core-rnaseq
        --gtf /home/lokeshwaran/nf-core-rnaseq/references/Homo_sapiens.GRCh38.109.gtf.gz \ # location of directory of references created for nf-core-rnaseq
        --gene_bed /home/lokeshwaran/nf-core-rnaseq/references/Homo_sapiens.GRCh38.109.bed \ # location of directory of references created for nf-core-rnaseq
        --input rnaseq_test_ss.csv \
        --skip_deseq2_qc \
        --outdir nfcore_rnaseq_output
    """ 
    stub:
    """
    mkdir -p nfcore_rnaseq_output
    """
}