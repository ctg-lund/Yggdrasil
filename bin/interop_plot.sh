#!/bin/bash
umask 002

verbose='false'

echo_debug(){
    echo_string=$1
    if [[ ${verbose} ==  "true" ]]; then
       echo ${echo_string}
    fi
}

echo_debug " ================================================================================="
echo_debug " ====                                                                         ==== "
echo_debug " ====                     --  ILLUMINA INTEROP PLOTTER  --                    ==== "
echo_debug " ====                  works only on NovaSeq InterOp folders                  ==== "
echo_debug " ====                                                                         ==== "
echo_debug " ================================================================================= "
echo_debug ""

#
# 	Usage:
#       Produce runfolder interop plots using Illunmina Python package (container ngs-tools.sif)
#
# 	Input:
#		A Illumina NovaSeq 6000 Runfolder wih /InterOp/ folder
#       Singularity container with python pagage (?), ngs-tools.sif

#	Output:
#       Multiple interop plots (png files)
#
#    Logfiles:
#      - No logfiles, standard out

################################################
##  == 1 ==  Parameters 
################################################

runfolder_path=$1
runfolder_name=$(basename "${runfolder_path}")
echo_debug " ... runfolder_name       : ${runfolder_name}"
echo_debug " ... runfolder_path  : ${runfolder_path}"
singularity_cmd='singularity exec --bind /projects/fs1/ /projects/fs1/shared/ctg-containers/ngs-tools/ngs-tools.sif'
echo_debug " ... singularity_cmd  : ${singularity_cmd}"
echo_debug ""
echo_debug ""



################################################
##  == 2 == Run Plot commands
################################################

# Nova: %Occupied vs %PF
if [[ "${runfolder_name}" == *"_A00"* ]]; then
    echo_debug " ... ok, this is a NovaSeq run! "
    echo_debug " ... generating:  interop_imaging_table "
    ${singularity_cmd} interop_imaging_table ${runfolder_path} | sed -e 's/;/,/g' |cut -d',' -f10,49 |  awk  -F "," '{ print $2,$1}' OFS="," | sed "s/,\#/\#/g" | grep -v "^," | gnuplot -e "set decimalsign locale 'en_US.utf8'; set title \"${runfolder}\";set datafile separator ',';set key autotitle columnheader;set term png;set output '${runfolder_path}/ctg-interop/occ_pf.${runfolder}_mqc.png'; set xrange [0:100]; set yrange [0:100]; set size square 1,1;set xlabel '% occupied'; set ylabel '% pass filter';set key off;plot '-'"
else
    echo_debug " ... this is not a NovaSeq run! "
    echo_debug " ... ... cannot generate interop_imaging_table "
fi

# Q-score Heatmap
echo_debug " ... generating:  interop_imaging_table "
${singularity_cmd} interop_plot_qscore_heatmap ${runfolder_path} | gnuplot

# Q-score-histogram
echo_debug " ... generating:  interop_imaging_table "
${singularity_cmd} interop_plot_qscore_histogram ${runfolder_path} | gnuplot

# Flowcell heatmap
echo_debug " ... generating:  interop_imaging_table "
${singularity_cmd} interop_plot_flowcell ${runfolder_path} | gnuplot

# Intensity by cycle
echo_debug " ... generating:  interop_imaging_table "
${singularity_cmd} interop_plot_by_cycle ${runfolder_path} | gnuplot 

# plot by lane, density / pf
echo_debug " ... generating:  interop_imaging_table "
${singularity_cmd} interop_plot_by_lane ${runfolder_path} | gnuplot 


################################################
##  == 3 ==  Finalize 
################################################

# change suffix - so it will be multiqc - compatible
echo_debug " ...  "
echo_debug " ... making MultiQC compatible"
for file in ${runfolder_name}*.png; do newn=$(echo ${file} | sed "s/.png/_mqc.png/g"); mv ${file} ${newn}; done

# move the pngs to runfolders interop folder
echo_debug " ... moving .png's to ./ctg-interop folder"
mv ${runfolder_name}*_mqc.png ${runfolder_path}/ctg-interop/


echo_debug ""
echo_debug " ====================================="
echo_debug "               D O N E    "
echo_debug " ====================================="
