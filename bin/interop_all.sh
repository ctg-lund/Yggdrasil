#!/bin/bash

runfolder_path=$1
runfolder_name=$(basename "${runfolder_path}")

mkdir -p interop_qc/"${runfolder_name}"

# Generating interop_summary (Python): "
interop_summary ${runfolder_path} --csv=1 > \
    interop_qc/"${runfolder_name}"/interop_summary

# Generating interop_index-summary (Python): "
interop_index-summary ${runfolder_path} --csv=1 > \
    interop_qc/"${runfolder_name}"/interop_index-summary

interop_imaging_table ${runfolder_path} | sed -e 's/;/,/g' |cut -d',' -f10,49 |  awk  -F "," '{ print $2,$1}' OFS="," | sed "s/,\#/\#/g" | grep -v "^," | gnuplot -e "set decimalsign locale 'en_US.utf8'; set title \"${runfolder_name}\";set datafile separator ',';set key autotitle columnheader;set term png;set output 'interop_qc/${runfolder_name}/occ_pf.${runfolder_name}_mqc.png'; set xrange [0:100]; set yrange [0:100]; set size square 1,1;set xlabel '% occupied'; set ylabel '% pass filter';set key off;plot '-'"
# Q-score Heatmap
interop_plot_qscore_heatmap ${runfolder_path} | gnuplot
# Flowcell heatmap
interop_plot_flowcell ${runfolder_path} | gnuplot
# Intensity by cycle
interop_plot_by_cycle ${runfolder_path} | gnuplot 
# plot by lane, density / pf
interop_plot_by_lane ${runfolder_path} | gnuplot 

# change suffix - so it will be multiqc - compatible
for file in ${runfolder_name}*.png; do \
    newn=$(echo ${file} | sed "s/.png/_mqc.png/g"); \
    mv ${file} ${newn}; \
done

# move the pngs to runfolders interop folder
mv ${runfolder_name}*_mqc.png interop_qc/"${runfolder_name}"/

# MultiQC
multiqc -f interop_qc/"${runfolder_name}"/ -n interop_qc/multiqc_${runfolder_name} 

mv interop_qc/multiqc_${runfolder_name}.html /projects/fs1/shared/ctg-qc/qcapp2/sequencing-runs/${runfolder_name}/qc/interop/multiqc_report.html
