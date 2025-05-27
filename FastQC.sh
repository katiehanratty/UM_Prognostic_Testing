#!/bin/bash

#RUNNING FASTQC

# Create a directory for fastqc outputs, edit pathway as needed
mkdir -p ~/fastq/raw_fastq/FASTQC/MultiQC

# Import raw paired fastq files into raw_fastq directory manually

# Run fastqc, and direct the outputs of the command to user's FASTQC subdirectory
fastqc ~/fastq/raw_fastq/*fastq.gz --outdir=~/fastq/raw_fastq/FASTQC

# Collate all reports using MultiQC for easier review
multiqc ~/fastq/raw_fastq/FASTQC --outdir=~/fastq/raw_fastq/FASTQC/MultiQC









