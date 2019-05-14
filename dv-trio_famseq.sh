#!/bin/bash
# dv-trio.sh
input=$1 #
# Initialise variables
input_vcf=''
ped=''
threshold='1.0'
ref=''
FAMSEQ_DIR='' #
echo "$(date) - Starting famseq postprocessing!"
#
# check the input file to see if it contain all samples details
echo "input file : "$input
#
while read line;     # do while there are lines from input file
do #
 read s_type other  <<< "$line" #
 read -d '\t' -r -a sample_val  <<< "$line" #
 if [ $s_type == "CCALL" ]; #
 then #
	input_vcf=${sample_val[1]}
 elif [ $s_type == "REF" ]; # 
 then # No
	ref=${sample_val[1]}
 elif [ $s_type == "PED" ]; # 
 then # No
	ped=${sample_val[1]}
 elif [ $s_type == "OUT" ]; # 
 then # No
	FAMSEQ_DIR=${sample_val[1]}
 elif [ $s_type == "THOLD" ]; # 
 then # No
	threshold=${sample_val[1]}
 fi #
done < $input # 
#
TEMP_DIR="${FAMSEQ_DIR}/temp"
#
mkdir -p "${TEMP_DIR}"
#
echo "trio ped : $ped" #
echo "trio_cocalled_vcf : $input_vcf" #
#
zcat $input_vcf > "${TEMP_DIR}/famseq_input.vcf"
#
echo "Decomposing and normalising samples..."
# Decompose and normalise all vcfs
vt decompose -s $TEMP_DIR/famseq_input.vcf -o $TEMP_DIR/famseq_input.dec.vcf 
vt decompose_blocksub -a $TEMP_DIR/famseq_input.dec.vcf -o $TEMP_DIR/famseq_input.dec.bs.vcf
vt normalize $TEMP_DIR/famseq_input.dec.bs.vcf -r $ref | vt uniq - -o $TEMP_DIR/famseq_input.dec.bs.processed.vcf
#bgzip $TEMP_DIR/famseq_input.dec.bs.processed.vcf
#tabix -p vcf $TEMP_DIR/famseq_input.dec.bs.processed.vcf
#
# need to clean up the VCF before running in FamSeq
sed "s|\.\/\.\:0\,0\:\.\:\.\:\.\:\.|\.\/\.\:0\,0\:0\:\.\:0\,0\,0\:\.|g" $TEMP_DIR/famseq_input.dec.bs.processed.vcf > $TEMP_DIR/famseq_input.dec.bs.processed.corr.vcf #
#
echo "Running FamSeq..."
FAMSEQ_OUTPUT="${FAMSEQ_DIR}/trio.FamSeq.vcf"
FamSeq vcf -vcfFile $TEMP_DIR/famseq_input.dec.bs.processed.corr.vcf -pedFile $ped -output ${FAMSEQ_OUTPUT} -a -LRC ${threshold}
sed -i 's/[ \t]*$//' $FAMSEQ_OUTPUT #
sed -i 's|PP\,Number\=G\,Type\=Integer|PP\,Number\=G\,Type\=Float|g' $FAMSEQ_OUTPUT #
###################
echo -e "OUT\t$FAMSEQ_OUTPUT" > $FAMSEQ_DIR/famseq_done.txt
echo "$(date) - FamSeq completed"

