#!/bin/bash

#RUNNING FASTQC

# Create a directory for fastqc outputs
mkdir ~/fastq/FASTQC
# Import raw paired fastq files manually

# Run fastqc, and direct the outputs of the command to user's FASTQC subdirectory
fastqc ~/fastq/*fastq.gz --outdir=~/fastq/FASTQC

# Collate all reports using MultiQC for easier review
multiqc ~/fastq/FASTQC









