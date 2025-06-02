#!/bin/sh

#RUNNING VARIANT EFFECT PREDICTOR

#set working directory to users VCF directory
#change file locations as required
cd ~/mutect2 || exit 1

#make a directory for VEP annotations of VCF file
mkdir ~/mutect2/VEP

#download ensembl VEP cache to parent directory (note-large file!)
#wget https://ftp.ensembl.org/pub/current_variation/indexed_vep_cache/homo_sapiens_vep_114_GRCh38.tar.gz 

#create loop for vep
for i in *.vcf; do 
vep --cache -i $i -fa ~/alignment/reference/hg38.fa \
--verbose --dir_cache ~ \
-o ~/mutect2/VEP/${i%.vcf}.vep \
--everything --fork 4 
done

#if you want to filter your VEP file to focus on a subset of UM genes: 
for i in *.vep; do
filter_vep -i $i -o ${i%.vep}.filtered.vep \
-f "SYMBOL in GNAQ,GNA11,BAP1,SF3B1,EIF1AX,NF1,PLCB4,CYSTLR2,PTP4A3,SRSF2,MDB4,MYC,CDKN2A,PIK3CA,PTEN,EZH2,MED12,PIK3R2,PBRM1"
done
#edit depending on genes wanted
