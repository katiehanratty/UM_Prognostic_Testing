
#PHASE TWO: DROPPING LOW COVERAGE AND PURITY NORMALISATION

#set working directory to users CNVkit output directory
#create revised cns files by dropping low coverage
for i in *.cnr; do
cnvkit.py segment $i --drop-low-coverage -o ${i%.cnr}.revised.cns
done

#run the call command using the revised cns
#if purity is known use that figure (get from FACETS analysis), if unknown leave blank
for i in *.revised.cns; do
cnvkit.py call $i -y -m clonal --purity X -o ${i%.cns}.call.cns #X = purity estimation

#run scatter to create a plot of the low coverage dropped and purity normalised data
cnvkit.py scatter ${i%.revised.call.cns}.cnr -s $i -o ${i%.call.cns}-scatter.png
done
