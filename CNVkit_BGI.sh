#RUNNING CNVkit with no matched samples available
#create access file
cnvkit.py access ~/alignment/reference/hg38.fa -o ~/CNVkit_analysis/bedfile/access.bed
#create flat reference
cnvkit.py reference -o FlatReference.cnn -f ~/alignment/reference/hg38.fa -t targets.bed -a antitargets.bed

#NO NORMAL SAMPLES (all BGI cases)
#used on tumour samples sequenced with different platform than cohort with matched samples

for tumour in *_tumour_sorted_filtered_nodup_RG.bam; do #edit depending on filenames
#save patient id into computer memory
patient_id=${patient_id%_tumour_sorted_filtered_nodup_RG.bam}
	echo "Processing patient: $patient_id"
cnvkit.py batch $tumour -r ~/CNVkit_analysis/FlatReference.cnn \
--targets ~/CNVkit_analysis/bedfile/Exome-Agilent_V6.bed \
--fasta ~/alignment/reference/hg38.fa \
--access ~/CNVkit_analysis/bedfile/access.bed \
--output-dir ~/CNVkit_analysis --scatter
done
