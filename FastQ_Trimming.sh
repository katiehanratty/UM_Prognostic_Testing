#!/bin/bash

#MAKE SURE YOU ARE IN THE DIRECTORY OF THE FASTQ FILES YOU WANT TO TRIM BEFORE RUNNING SCRIPT
#e.g. ~/fastq/raw_fastq

#make a directory for the trimmed fastq
mkdir -p ~/fastq/trimmed_fastq/FastQC/MultiQC
mkdir -p ~/fastq/trimmed_fastq/logs

#save path for fastq in memory
TRIMMED=/mnt/data/GCB2025/katiehanratty/fastq/trimmed_fastq #edit parent directory as required

#####################RUNNING CUTADAPT#####################
#change sequence (-a, -A) as needed (This is Illumina adapter) and other options as required
for i in *_1.fastq.gz; do
cutadapt -j=1 -a AGATCGGAAGAG -A AGATCGGAAGAG \
--output=${TRIMMED}/trimmed_$i --paired-output=${TRIMMED}/trimmed_${i%_1.fastq.gz}_2.fastq.gz \
--error-rate=0.1 --times=1 --overlap=3 --action=trim --minimum-length=35 \
--pair-filter=any --quality-cutoff=20 \
$i ${i%_1.fastq.gz}_2.fastq.gz > ${TRIMMED}/logs/trimmed_${i%_1.fastq.gz}_cutadapt.log
done

#run fastqc and multiqc on the trimmed files
fastqc ${TRIMMED}/*.fastq.gz --outdir=${TRIMMED}/FastQC
multiqc ${TRIMMED}/FastQC --outdir=${TRIMMED}/FastQC/MultiQC
