process FASTQC {

	input:
		path(demux_dir)
	output:
        path "qc*"
	shell:
	"""
    # Fastqc scripts
	"""
	stub:
	"""
    mkdir -p qc/fastqc
    touch qc/fastqc/sample_id.fastqc.html
	"""
}