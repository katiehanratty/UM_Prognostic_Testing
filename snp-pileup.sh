#!/bin/bash

#make sure you are in the bamfiles directory before running the script.

######################CREATE SNP PILEUP FILE FOR FACETS###########################

#make directory for FACETS
mkdir -p ~/FACETS/VCF

#download general VCF file available from FTP server ( 00-common_all.vcf reccommended)
#wget  ftp://ftp.ncbi.nlm.nih.gov/snp/organisms/human_9606/VCF/00-common_all.vcf.gz

#unzip that VCF and sort it numerically (need to ensure FACETS run correctly)
gunzip ~/FACETS/VCF/00-common_all.vcf.gz cat ~/FACETS/VCF/00-common_all.vcf \
| awk '$1 ~ /^#/ {print $0;next} {print $0 | "sort -k1,1 -k2,2n"}' > ~/FACETS/VCF/out_sorted.vcf

#start loop for snp-pileup
for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do
#save patient id in computer memory
patient_id=${tumour#trimmed_}
patient_id=${patient_id%_tumour_sorted_filtered_nodup_RG.bam}
normal=trimmed_${patient_id}_normal_sorted_filtered_nodup_RG.bam #change filenames as needed
	if [[ -f $normal ]]; then
	echo "Processing patient: $patient_id"
	snp-pileup ~/FACETS/VCF/out_sorted.vcf ~/FACETS/$patient_id.pileup $normal $tumour
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done

#sort pileup file (need to ensure FACETS run correctly)
for i in ~/FACETS/*.pileup; do
head -n 1 $i && tail -n +2 $i | sort -t, -k1,1V -k2,2n > ~/FACETS/${i%.pileup}.sorted.pileup
done

