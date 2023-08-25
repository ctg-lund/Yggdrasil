#!/usr/bin/env bash

$fastq_loc=$1

echo "sample,fastq_1,fastq_2,strandedness" > rnaseq_ss.csv
ls -1 --color=never $fastq_loc/*fastq.gz| grep _R2_ |perl -pe 's/(.+\/(.+)_S\d+_.+)/\2,\1,\1,auto/'|perl -pe 's/_R2_/_R1_/' >> rnaseq_ss.csv