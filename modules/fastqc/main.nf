process FASTQC {
	tag "${proj}"
	
	input:
	tuple val(proj), path(demux_dir)
	
	output:
	tuple val(proj), path(demux_dir), emit demux_out
	tuple val(proj), path("${proj}_fastqc/*.zip") , emit: zip
	
	shell:
	"""
	mkdir -p ${proj}_fastqc
	yg_fastqc.sh ${demux_dir} ${proj}_fastqc
	"""
	
	stub:
	"""
    mkdir -p proj_fastqc
	touch proj_fastqc/sample_id.fastqc.html
	touch proj_fastqc/sample_id.fastqc.zip
	"""
}