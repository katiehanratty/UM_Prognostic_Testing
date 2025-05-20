#!/bin/bash

#set working directory to users fastq directory
cd ~/fastq

#run cutadapt 
for i in *_1.fastq.gz; do
cutadapt -j=1 -a AGATCGGAAGAG -A AGATCGGAAGAG \  #change sequence as needed (This is Illumina adapter)
--output=trimmed_$i --paired-output=trimmed_${i%_1.fastq.gz}_2.fastq.gz \
--error-rate=0.1 --times=1 --overlap=3 --action=trim --minimum-length=35 \ 
--pair-filter=any --quality-cutoff=20 \ 
$i ${i%_1.fastq.gz}_2.fastq.gz > trimmed_${i%_1.fastq.gz}_cutadapt.log   #adjust other options as required
done

#move trimmed files to their own directory 
mkdir -p trimmed_fastq/FastQC/MultiQC
mv trimmed*fastq.gz trimmed_fastq

#run fastqc and multiqc on the trimmed files
cd trimmed_fastq
fastqc *.fastq.gz --outdir=FastQC
multiqc trimmed_fastq/FastQC --outdir=./trimmed_fastq/FastQC/MultiQC
