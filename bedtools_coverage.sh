#MAKING THE FILES FOR BEDTOOLS COVERAGE TO ASSESS BAM
# making a histogram of the BAM file then filtering column one to just rows with 'all'

for i in *.bam; do
bedtools coverage -hist -a ~/CNVkit/bedfile/Exome-Agilent_V6.bed -b $i > ${i%.bam}_depth.txt
awk '$1=="all"{print $0}' ${i%.bam}_depth.txt > ${i%.bam}_depth_all.txt
done
