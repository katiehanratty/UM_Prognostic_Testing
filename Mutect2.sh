#!/bin/sh

#Running Mutect2 (Somaitc Variant Calling)

#MAKE SURE YOU ARE IN THE DIRECTORY OF THE BAM FILES YOU WANT TO VARIANT CALL

#make a new directory for your renamed BAM files (Mutect2 only works if files renamed to the sample name used in the BAM reads)
mkdir -p ~/alignment/bamfiles/filtered_bam/150bp/mutect2

#rename files using mv
cp *.bam mutect2
for i in ~/alignment/bamfiles/filtered_bam/150bp/mutect2/*.bam; do
mv $i ${i%_sorted_filtered_nodup_RG.bam} 
done

#create directory for your mutect2 VCF files
mkdir -p ~/mutect2/normals

#CREATE PANEL OF NORMALS

#first run every normal sample through tumor-only Mutect2 (to create Panel of Normals)
for i in ~/alignment/bamfiles/filtered_bam/150bp/mutect2/trimmed_patient*_normal; do 
gatk Mutect2 -R ~/alignment/reference/hg38.fa -I $i -tumor $i \
-O ~/mutect2/normals/${i%.bam}.vcf.gz
done 

#make an arg file of all the normal files (a list file)
ls ~/mutect2/normals/*.vcf.gz >  ~/mutect2/normals/normals_for_pon_vcf.args

#use gatk command to create panel
gatk CreateSomaticPanelOfNormals --vcfs  ~/mutect2/normals/normals_for_pon_vcf.args \ 
-O ~/mutect2/normals/PON.vcf.gz 

#RUN SOMATIC VARIANT CALLING

for tumour in ~/alignment/bamfiles/filtered_bam/150bp/mutect2/trimmed_*_tumour; do
#save patient id in computer memory
patient_id=${tumour#trimmed_}
patient_id=${patient_id%_tumour}
normal="trimmed_${patient_id}_normal"
	if [[ -f $normal ]]; then
	echo "Processing patient: $patient_id"
	gatk Mutect2 -I $normal -I $tumour -R ~/alignment/reference/hg38.fa \
	--tumor-sample $tumour --normal-sample $normal \
	--panel-of-normals ~/mutect2/normals/PON.vcf.gz \
	-O ~/mutect2/$patient_id.somatic.vcf.gz
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done

for i in ~/mutect2/*.vcf.gz; do
gatk FilterMutectCalls -V $i -O ~/mutect2/${i%.vcf.gz}.filtered.vcf.gz
done
