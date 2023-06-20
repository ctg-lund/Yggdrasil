process FASTQC {
	tag "${proj}"
	input:
	tuple val(proj), path(demux_dir)
	
	output:
	tuple val(proj), path("${proj}_fastqc/*.zip") , emit: zip
	
	shell:
	"""
	mkdir -p ${proj}_fastqc
	fastqc --threads 8 -o ${proj}_fastqc ${demux_dir}/*gz 
	"""
	
	stub:
	"""
    mkdir -p ${proj}_fastqc
	touch ${proj}_fastqc/sample_id.fastqc.html
	touch ${proj}_fastqc/sample_id.fastqc.zip
	"""
}