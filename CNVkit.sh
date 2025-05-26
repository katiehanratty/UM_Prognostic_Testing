#!/bin/bash

#RUNNING CNVKIT

#make directories for your target bedfile and your bam cohorts
mkdir -p ~/CNVkit/bedfiles
mkdir -p ~/CNVkit/150bp
mkdir -p ~/CNVkit/151bp
mkdir ~/alignment/bamfiles/filtered_bam/150bp/matched
mkdir ~/alignment/bamfiles/filtered_bam/150bp/unmatched

#same pathways into memory, edit as needed depending on users directory names
REFERENCE=~/alignment/reference/hg38.fa
BEDFILES=~/CNVkit/bedfiles
BAMFILES=~/alignment/bamfiles/filtered_bam
MATCHED=~/alignment/bamfiles/filtered_bam/150bp/matched
UNMATCHED=~/alignment/bamfiles/filtered_bam/150bp/unmatched

#manually download exome kit bedfile from company website to the bedfiles directory 
#for my files, Agilent v6 Exon Capture kit was used. 

#set working directory to users bamfile directory
cd ${BAMFILES}/150bp #edit as needed (e.g. for 150bp, 151bp, etc)

#create access bedfile for use in command
cnvkit.py access ${REFERENCE} -o ${BEDFILES}/access.bed

#PHASE ONE: NO NORMALISATION

cnvkit.py batch trimmed_*_tumour_sorted_filtered_nodup_RG.bam --normal trimmed_*_normal_sorted_filtered_nodup_RG.bam \
--targets ${BEDFILES}/Exome-Agilent_V6.bed \
--fasta ${REFERENCE} \
--access ${BEDFILES}/access.bed \
--output-dir ~/CNVkit/150bp --scatter #edit output directory name as needed
