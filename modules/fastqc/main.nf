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
<<<<<<< HEAD
    mkdir -p ${proj}_fastqc
=======
    mkdir -p proj_fastqc
>>>>>>> 2c29f2bdbc4d793b6700bda3d977b71f4b4167ff
	touch ${proj}_fastqc/sample_id.fastqc.html
	touch ${proj}_fastqc/sample_id.fastqc.zip
	"""
}