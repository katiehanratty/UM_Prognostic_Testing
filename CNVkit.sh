#!/bin/bash

#RUNNING CNVKIT

#make directories for your target bedfile and your bam cohorts
mkdir -p ~/CNVkit/bedfiles
mkdir -p ~/CNVkit/150bp
mkdir -p ~/CNVkit/151bp
mkdir -p ~/alignment/bamfiles/filtered_bam/150bp/matched
mkdir -p ~/alignment/bamfiles/filtered_bam/150bp/unmatched

#same pathways into memory, edit as needed depending on users directory names
REFERENCE=/mnt/data/GCB2025/katiehanratty/alignment/reference/hg38.fa
BEDFILES=/mnt/data/GCB2025/katiehanratty/CNVkit/bedfiles
BAMFILES=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles/filtered_bam
MATCHED=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles/filtered_bam/150bp/matched
UNMATCHED=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles/filtered_bam/150bp/unmatched

#manually download exome kit bedfile from company website to the bedfiles directory 
#for my files, Agilent v6 Exon Capture kit was used. 
#note: step already done for bedtools coverage. Can cp this bedfile in
cp ~/alignment/bedtools/bedfile/Exome-Agilent_V6.bed $BEDFILES

#set working directory to users bamfile directory
cd ${BAMFILES}/150bp || exit 1 #edit as needed

#create access bedfile for use in command
cnvkit.py access ${REFERENCE} -o ${BEDFILES}/access.bed

#PHASE ONE: NO NORMALISATION

cnvkit.py batch trimmed_*_tumour_sorted_filtered_nodup_RG.bam \
--normal trimmed_*_normal_sorted_filtered_nodup_RG.bam \
--targets ${BEDFILES}/Exome-Agilent_V6.bed \
--fasta ${REFERENCE} \
--access ${BEDFILES}/access.bed \
--output-dir ~/CNVkit/150bp --scatter #edit output directory name as needed

#PHASE TWO: DROPPING LOW COVERAGE AND PURITY NORMALISATION

#set working directory to users CNVkit output directory
cd ~/CNVkit/150bp || exit 1
#make a directory for the revised CNS, CALL, and SCATTER files
mkdir -p ~/CNVkit/150bp/revised

#create loop to resegment, normalise copy number calls using clonal purity normalisation
#and produce scatter plots 
for i in *.cnr; do
#drops low coverage reads
cnvkit.py segment $i --drop-low-coverage -o ~/CNVkit/150bp/revised/${i%.cnr}.revised.cns
#normalised sample for purity and infers integer copy numbers
#if purity is known use that figure after --purity (e.g. --purity 0.3). 
#Purity estimations can be made from FACETS analysis. If unknown, leave blank like below
cnvkit.py call ~/CNVkit/150bp/revised/${i%.cnr}.revised.cns -y -m clonal --purity -o ~/CNVkit/150bp/revised/${i%.cnr}.revised.call.cns
cnvkit.py scatter $i -s ~/CNVkit/150bp/revised/${i%.cnr}.revised.call.cns -o ~/CNVkit/150bp/revised/${i%.cnr}.revised.call.scatter.png
done
