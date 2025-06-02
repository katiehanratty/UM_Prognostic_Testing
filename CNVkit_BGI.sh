#NO NORMAL SAMPLES (all BGI cases)
#used on tumour samples sequenced with different platform than cohort with matched samples

mkdir -p ~/CNVkit/BGI/revised

REFERENCE=/mnt/data/GCB2025/katiehanratty/alignment/reference/hg38.fa
BEDFILES=/mnt/data/GCB2025/katiehanratty/CNVkit/bedfiles
BAMFILES=/mnt/data/GCB2025/katiehanratty/alignment/bamfiles/filtered_bam/BGI
CNVKIT=/mnt/data/GCB2025/katiehanratty/CNVkit/

#create access file (if running this after other script (CNVkit.sh) do not need to do this.
cnvkit.py access ${REFERENCE} -o ${BEDFILES}/access.bed

#create flat reference (reuse the target.bed and antitarget.bed files created by the previous
#Novogene/eurofins runs if the same exome capture kit was used)
cnvkit.py reference -o ${CNVKIT}/BGI/FlatReference.cnn -f ${REFERENCE} \
-t ${CNVKIT}/150bp/Exome-Agilent_V6.targets.bed -a ${CNVKIT}/150bp/Exome-Agilent_V6.antitargets.bed 

cnvkit.py batch ${BAMFILES}/*_tumour_sorted_filtered_nodup_RG.bam -r ${CNVKIT}/BGI/FlatReference.cnn \
--targets ${BEDFILES}/Exome-Agilent_V6.bed \
--fasta ${REFERENCE} \
--access ${BEDFILES}/access.bed \
--output-dir ${CNVKIT}/BGI
done

#PHASE TWO: DROPPING LOW COVERAGE AND PURITY NORMALISATION

#create loop to resegment, normalise copy number calls using clonal purity normalisation
#and produce scatter plots 
for i in ${CNVKIT}/BGI/*.cnr; do
#drops low coverage reads
cnvkit.py segment $i --drop-low-coverage -o ${CNVKIT}/BGI/revised/${i%.cnr}.revised.cns
#normalised sample for purity and infers integer copy numbers
#if purity is known use that figure after --purity (e.g. --purity 0.3). 
#Purity estimations can be made from FACETS analysis. If unknown, leave blank like below
cnvkit.py call ${CNVKIT}/BGI/revised/${i%.cnr}.revised.cns -y -m clonal --purity -o ${CNVKIT}/BGI/revised/${i%.cnr}.revised.call.cns
cnvkit.py scatter $i -s ${CNVKIT}/BGI/revised/${i%.cnr}.revised.call.cns -o ${CNVKIT}/BGI/revised/${i%.cnr}.revised.call.scatter.png
done
