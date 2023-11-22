 #!/bin/bash
umask 002
# Usage:
# bash interop_qc.sh /path/to/runfolder
runfolder_path=$1
runfolder_name=$(basename ${runfolder_path})
interop_id="ctg_interop_${runfolder_name}"
ctg_qc_out="/projects/fs1/shared/ctg-qc/interop"
interop_out="$ctg_qc_out"
interop_plots_script="/projects/fs1/shared/Yggdrasil/bin/interop_plot.sh"
## singularity container/command for python scripts
singularity_cmd="singularity exec --bind /projects/ /projects/fs1/shared/ctg-containers/ngs-tools/ngs-tools.sif"
mkdir -p ${interop_out}
# Generating interop_summary (Python): "
${singularity_cmd} interop_summary ${runfolder_path} --csv=1 > ${interop_out}/interop_summary
# Generating interop_index-summary (Python): "
${singularity_cmd} interop_index-summary ${runfolder_path} --csv=1 > ${interop_out}/interop_index-summary
# Generating interop qc plots (./bin/interop-plots.sh): "
# bash /projects/fs1/shared/ctg-tools/bin/ctg-interop-plots.sh ${runfolder_path}
bash ${interop_plots_script} ${runfolder_path}
${singularity_cmd} multiqc -f ${interop_out} -n ${interop_out}/multiqc_${interop_id} 

