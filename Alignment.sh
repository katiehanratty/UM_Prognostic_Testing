#!/bin/sh

#MAKE SURE YOU ARE IN THE DIRECTORY OF THE FASTQ FILES OYU WANT TO ALIGN BEFORE RUNNING SCRIPT

#MAKE DIRECTORIES FOR ALIGNMENT, edit as required
mkdir -p ~/alignment/bamfiles
mkdir -p ~/alignment/samfiles
mkdir -p ~/alignment/reference
SAMFILES=/mnt/data/GCB2025/katiehanratty/alignment/samfiles
BAMFILES=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles
REFERENCE=/mnt/data/GCB2025/katiehanratty/alignment/reference

#DOWNLOAD REFERENCE SEQUENCE OF CHOICE TO REFERENCE DIRECTORY USING WGET

##### ALIGN FASTQ TO REFERENCE #####

#CREATE LOOP FOR BWA ALIGNMENT
for i in *_R1.fastq.gz; do
bwa mem -t 8 $REFERENCE/hg38.fa $i \
${i%_R1.fastq.gz}_R2.fastq.gz > $SAMFILES/${i%_R1.fastq.gz}.sam

#SAM TO BAM, SORTING AND INDEXING BAM FILE
samtools view -b $SAMFILES/${i%_R1.fastq.gz}.sam | samtools sort -o $BAMFILES/${i%_R1.fastq.gz}_sorted.bam
samtools index $BAMFILES/${i%_R1.fastq.gz}_sorted.bam
done 

