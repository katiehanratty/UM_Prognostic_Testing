#!/bin/sh

#save pathway with bamfiles in memory
ALIGNED=~/alignment/bamfiles   #edit for directory name as needed

#create subdirectories for intermediate and raw files
mkdir -p ~/alignment/bamfiles/intermediate_files
mkdir -p ~/alignment/bamfiles/raw_bam
mkdir -p ~/alignment/bamfiles/filtered_bam
mkdir -p ~/alignment/bamfiles/metrics

#OBTAIN READ GROUP INFORMATION FROM FASTQ FILES

#set working directory to directory with the fastq files
cd ~/fastq/trimmed_fastq || exit 1 #stops script running if the cd doesn't run properly

#start loop
for fastqname in *R1.fastq.gz; do #edit for filenames as needed
echo "fastq file: $fastqname"
subject=${fastqname%_R1.fastq.gz} 
echo "subject: $subject"
#extract header from fastq file for readgroup creation 
fastq_header1=`gunzip -c $fastqname | head -n1| awk '{print $1}'`
fastq_header2=`gunzip -c $fastqname | head -n1| awk '{print $2}'`

#extract each element from the fastq headers and save each field in memory
#NOTE:Ensure fastq header in colon delimited format. If not (e.g. BGI data) extract and view headers between reads
#and between files to figure out which field likely represents run id, flowcell id, lane id, etc to use for read group id.

IFS=: read -a fields1 <<< "$fastq_header1"
run_id=`echo ${fields1[1]}`
flowcell_id=`echo ${fields1[2]}`
lane=`echo ${fields1[3]}`

IFS=: read -a fields2 <<< "$fastq_header2"
index=`echo ${fields2[3]}`

#print each element to the terminal 
echo "run id is $run_id, flowcell id is $flowcell_id, lane is $lane, index is $index"
#readgroup=@RG"\t"ID:${run_id}.${lane}.${index}_${subject}"\t"LB:Batch1.${subject}"\t"SM:${subject}"\t"PL:ILLUMINA"\t"PU:${flowcell_id}.${lane}.${index}_${subject}
#echo "readgroup is: $readgroup"

#save these in memory
RGID=ID:${run_id}.${lane}.${index}_${subject} #edit for files as needed
RGLB=Batch1.${subject}
RGSM=${subject}
RGPL=ILLUMINA #edit for platform as needed
RGPU=${flowcell_id}.${lane}.${index}_${subject}
echo "RGID is: $RGID"
echo "RGLB is: $RGLB"
echo "RGSM is: $RGSM"
echo "RGPL is: $RGPL"
echo "RGPU is: $RGPU"
echo ""

#ADDING THE READGROUP INFORMATION TO BAMFILES

echo "Adding read group information to ${fastqname%_R1.fastq.gz}_sorted.bam:"
date +"%c"
picard AddOrReplaceReadGroups \
I=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted.bam \
O=${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_RG.bam \
RGID=$RGID \
RGLB=$RGLB \
RGPL=$RGPL \
RGPU=$RGPU \
RGSM=$RGSM \
VALIDATION_STRINGENCY=LENIENT
date +"%c"
echo ""

#FILTERING BAM

#remove non-primary alignments and reads with MAPQ<10
echo "Removing non-primary alignments and ambiguous reads (MAPQ<10) from ${fastqname%_R1.fastq.gz}_sorted_RG.bam:"
date +"%c"
#removing supplementary and MAPQ<10 alignments
samtools view -b -F 2048 -q 10 \
${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_RG.bam \
> ${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp.bam
date +"%c"
echo ""
#removing secondary alignments
samtools view -b -F 256 \
${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_RG_temp.bam \
> ${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp2.bam
date +"%c"
echo ""

#remove unmapped reads with MAPQ>0
echo "Removing unmapped reads with MAPQ>0 from ${fastqname%_R1.fastq.gz}_sorted_reads_RG.bam:"
date +"%c"
samtools view -b -F 4 \
${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp2.bam \
> ${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam
date +"%c"
echo ""
#remove duplicate reads
echo "Removing duplicates from filtered ${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam:"
date +"%c"
picard MarkDuplicates INPUT=${ALIGNED}/intermediate_files/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam \
OUTPUT=${ALIGNED}/filtered_bam/${fastqname%_R1.fastq.gz}_sorted_filtered_nodup_RG.bam \
REMOVE_DUPLICATES=true \
METRICS_FILE=${ALIGNED}/metrics/${fastqname%_R1.fastq.gz}_sorted_filtered_nodup_RG_metrics.txt \
VALIDATION_STRINGENCY=LENIENT
date +"%c"
echo ""

#move files into respective directories
mv ${fastqname%_R1.fastq.gz}_sorted.bam ${ALIGNED}/raw_bam

done
