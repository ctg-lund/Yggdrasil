process NFCORE_RNASEQ {
	tag "${proj}"
	input:
	tuple val(proj), path(demux_dir), path(qc_dir)

    output:
    tuple val(proj), path("nfcore_rnaseq_output"), emit: rnaseq_out

    shell:
    """
    export NXF_OFFLINE='TRUE'
    /projects/fs1/shared/external-tools/nextflow/23.04.1/nextflow \ #correct location of the working nextflow binary
        run /projects/fs1/shared/nfcore_rnaseq/ \ # correct location of the nf-core-rnaseq workflow directory
        -profile ctg \
        -c /projects/fs1/shared/nfcore_rnaseq/configs/ctg_rnaseq.config \ #location of ctg_rnaseq.config 
        --fasta /projects/fs1/shared/references/hg38/genome/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa \ # location of reference genome
        --gtf /projects/fs1/shared/references/hg38/annotation/gtf/gencode/v33/gencode.v33.annotation.gtf \ # location of reference gtf
        --gene_bed /projects/fs1/shared/references/hg38/annotation/gtf/gencode/v33/gencode.v33.annotation.genes.bed \ # location of reference bed
        --input rnaseq_test_ss.csv \
        --outdir nfcore_rnaseq_output
    """ 
    stub:
    """
    mkdir -p nfcore_rnaseq_output
    """
}