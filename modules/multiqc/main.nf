process MULTIQC {
	tag "${proj}"
	
	input:
	tuple val(proj), path(demux_dir)
	tuple val(proj), path(zips)
	
	output:
	tuple val(proj), path(demux_dir)
	path "qc*"
	
	shell:
	"""
	mkdir -p qc
	multiqc -s -n fastqc_multiqc.html -o qc/ ${zips}
	"""
	
	stub:
	"""
	mkdir -p qc/multiqc
	touch qc/multiqc/all_samples.multiqc.html
	"""
}