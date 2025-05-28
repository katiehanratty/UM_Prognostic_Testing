#!/bin/sh

#RUNNING VARIANT EFFECT PREDICTOR

#set working directory to users VCF directory
#change file locations as required
cd ~/mutect2

#make a directory for VEP annotations of VCF file
mkdir ~/mutect2/VEP

#download ensembl VEP cache to parent directory (note-large file!)
wget https://ftp.ensembl.org/pub/current_variation/indexed_vep_cache/homo_sapiens_vep_114_GRCh38.tar.gz 

#create loop for vep
for i in *.vcf; do 
vep --cache -i $i -fa ~/alignment/reference/hg38.fa \
--verbose --dir_cache ~/cache \
-o ~/mutect2/VEP/${i%.vcf}.vep \
--everything --fork 4 
done
