#!/bin/bash

#make a directory for the trimmed fastq
mkdir -p ~/fastq/trimmed_fastq/FastQC/MultiQC
TRIMMED=/mnt/data/GCB2025/katiehanratty/fastq/trimmed_fastq #edit parent directory as required

#set working directory to users raw fastq directory
cd ~/fastq/raw_fastq

#run cutadapt 
#change sequence (-a, -A) as needed (This is Illumina adapter) and other options as required
for i in *_1.fastq.gz; do
cutadapt -j=1 -a AGATCGGAAGAG -A AGATCGGAAGAG \
--output=${TRIMMED}/trimmed_$i --paired-output=${TRIMMED}/trimmed_${i%_1.fastq.gz}_2.fastq.gz \
--error-rate=0.1 --times=1 --overlap=3 --action=trim --minimum-length=35 \
--pair-filter=any --quality-cutoff=20 \
$i ${i%_1.fastq.gz}_2.fastq.gz > trimmed_${i%_1.fastq.gz}_cutadapt.log
done

#move trimmed files to their own directory 
mv *.log ${TRIMMED}

#run fastqc and multiqc on the trimmed files
fastqc ${TRIMMED}/*.fastq.gz --outdir=${TRIMMED}/FastQC
multiqc ${TRIMMED}/FastQC --outdir=${TRIMMED}/FastQC/MultiQC
