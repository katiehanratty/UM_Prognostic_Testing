#!/bin/bash

##################RUNNING CNVKIT###############################

#make directories for your target bedfile and your bam cohorts
mkdir -p ~/CNVkit/bedfiles
mkdir -p ~/CNVkit/150bp/revised
mkdir -p ~/CNVkit/151bp/revised

#same pathways into memory, edit as needed depending on users directory names
REFERENCE=/mnt/data/GCB2025/katiehanratty/alignment/reference/hg38.fa
BEDFILES=/mnt/data/GCB2025/katiehanratty/CNVkit/bedfiles
BAMFILES=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles/filtered_bam/150bp #edit to 151bp as required
CNVKIT=/mnt/data/GCB2025/katiehanratty/CNVkit/150bp

#manually download exome kit bedfile from company website to the bedfiles directory 
#for my files, Agilent v6 Exon Capture kit was used. 
#note: step already done for bedtools coverage. Can cp this bedfile in
cp ~/alignment/bedtools/bedfile/Exome-Agilent_V6.bed ${BEDFILES}

#create access bedfile for use in command
cnvkit.py access ${REFERENCE} -o ${BEDFILES}/access.bed

#PHASE ONE: NO NORMALISATION

cnvkit.py batch ${BAMFILES}/trimmed_*_tumour_sorted_filtered_nodup_RG.bam \
--normal ${BAMFILES}/trimmed_*_normal_sorted_filtered_nodup_RG.bam \
--targets ${BEDFILES}/Exome-Agilent_V6.bed \
--fasta ${REFERENCE} \
--access ${BEDFILES}/access.bed \
--output-dir ${CNVKIT} --scatter #edit output directory name as needed

#PHASE TWO: DROPPING LOW COVERAGE AND PURITY NORMALISATION

#create loop to resegment, normalise copy number calls using clonal purity normalisation
#and produce scatter plots 
for i in ${CNVKIT}/*.cnr; do
#drops low coverage reads
cnvkit.py segment $i --drop-low-coverage -o ${CNVKIT}/revised/${i%.cnr}.revised.cns
#normalised sample for purity and infers integer copy numbers
#if purity is known use that figure after --purity (e.g. --purity 0.3). 
#Purity estimations can be made from FACETS analysis. If unknown, leave blank like below
cnvkit.py call ${CNVKIT}/revised/${i%.cnr}.revised.cns -y -m clonal --purity -o ${CNVKIT}/revised/${i%.cnr}.revised.call.cns
cnvkit.py scatter $i -s ${CNVKIT}/revised/${i%.cnr}.revised.call.cns -o ${CNVKIT}/revised/${i%.cnr}.revised.call.scatter.png
done
