#MAKING THE FILES FOR BEDTOOLS COVERAGE TO ASSESS BAM
# making a histogram of the BAM file then filtering column one to just rows with 'all'

#download the target exome capture kit bedfile into a directory, in order to calculate the 
#level of coverage in the target regions (i.e. the exonic regions).
#e.g: Agilent v6 https://github.com/AstraZeneca-NGS/reference_data/blob/master/hg38/bed/Exome-Agilent_V6.bed 

#make a directory for the target bedfile and bedtools coverage analysis files
#edit as required
mkdir -p ~/alignment/bedtools/bedfile

#save bedtools and bamfiles path in memory
BEDTOOLS=/mnt/data/GCB2025/katiehanratty/alignment/bedtools
BAMFILES=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles/filtered_bam/150bp #edit as required

#create loop for bedtools coverage
for i in ${BAMFILES}/*.bam; do
bedtools coverage -hist -a $BEDTOOLS/bedfile/Exome-Agilent_V6.bed -b $i > $BEDTOOLS/${i%.bam}_depth.txt
awk '$1=="all"{print $0}' $BEDTOOLS/${i%.bam}_depth.txt > $BEDTOOLS/${i%.bam}_depth_all.txt
done
