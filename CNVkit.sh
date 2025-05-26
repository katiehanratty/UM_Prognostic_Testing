#!/bin/bash

#RUNNING CNVKIT

#download bedfile for the specific exome kit used from company website
#set working directory to users bamfile directory

#create access bedfile for use in command
cnvkit.py access ~/alignment/reference/hg38.fa -o ~/CNVkit_analysis/bedfile/access.bed

#PHASE ONE: NO NORMALISATION

#MATCHED SAMPLES (all Eurofins, some Novogene)

for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do #edit depending on filenames
#save patient id into computer memory
patient_id=${tumour#trimmed_}
patient_id=${patient_id%_tumour_sorted_filtered_nodup_RG.bam}
normal="trimmed_${patient_id}_normal_sorted_filtered_nodup_RG.bam"
	if [[ -f $normal ]]; then
	echo "Processing patient: $patient_id"
	cnvkit.py batch $tumour --normal $normal \
	--targets ~/CNVkit_analysis/bedfile/Exome-Agilent_V6.bed \
	--fasta ~/alignment/reference/hg38.fa \
	--access ~/CNVkit_analysis/bedfile/access.bed \
	--output-dir ~/CNVkit_analysis --scatter
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done

#UNMATCHED SAMPLES (some Novogene)
#used on tumour samples sequenced with same platform as a cohort with matched samples
#reuses reference built from normal pooled samples

for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do #edit depending on filenames
	echo "Processing patient: $patient_id"
	cnvkit.py batch $tumour 
	-r ~/CNVkit_analysis/Reference.cnn #reference built from previous matched sample analysis
	-t targets.bed -a antitargets.bed -g access.bed #targets and antitargets also build previously
	--output-dir ~/CNVkit_analysis --scatter
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done
