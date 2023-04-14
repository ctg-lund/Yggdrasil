process FASTQC {
	tag "${proj}"
	
	input:
		tuple val(proj), path(demux_dir)
	
	output:
		tuple val(proj), path(demux_dir)
		path "qc*"
	
	shell:
	"""
    # Fastqc and multiqc together for each project scripts
	"""
	
	stub:
	"""
    mkdir -p qc/fastqc
	mkdir -p qc/multiqc
	touch qc/fastqc/sample_id.fastqc.html
	touch qc/multiqc/all_samples.multiqc.html
	"""
}