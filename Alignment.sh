#!/bin/sh

#MAKE DIRECTORY FOR ALIGNMENT
mkdir -p ~/alignment/bamfiles
mkdir -p ~/alignment/samfiles

#DOWNLOAD REFERENCE SEQUENCE OF CHOICE TO REFERENCE DIRECTORY
mkdir ~/alignment/reference
wget #add in link to ftp server's reference wanted 

#ALIGN FASTQ TO REFERENCE 

#MOVE INTO DIRECTORY WITH FASTQ FILES
cd ~/fastq  #adjust if files are in trimmed section

#CREATE LOOP
for i in *_R1.fastq.gz; do
bwa mem -t 8 ~/alignment/reference/hg38.fa $i \  #edit threads (-t) as needed
${i%_R1.fastq.gz}_R2.fastq.gz > ${i%_R1.fastq.gz}.sam

#SAM TO BAM, SORTING AND INDEXING BAM FILE
samtools view -b ${i%_R1.fastq.gz}.sam | samtools sort -o ${i%_R1.fastq.gz}_sorted.bam
samtools index ${i%_R1.fastq.gz}_sorted.bam
done 

#MOVE FILES TO BAMFILE/SAMFILE DIRECTORY
mv *.bam ~/alignment/bamfiles
mv *.sam ~/alignment/samfiles

