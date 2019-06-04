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
FAMSEQ_MOD_OUTPUT="${FAMSEQ_DIR}/trio.FamSeq_mod.vcf"
FamSeq vcf -vcfFile $TEMP_DIR/famseq_input.dec.bs.processed.corr.vcf -pedFile $ped -output ${FAMSEQ_OUTPUT} -a -LRC ${threshold}
sed -i 's/[ \t]*$//' $FAMSEQ_OUTPUT #
sed -i 's|PP\,Number\=G\,Type\=Integer|PP\,Number\=G\,Type\=Float|g' $FAMSEQ_OUTPUT #
#
#save original GT value and move Famseq GT to be the GT value for sample
bcftools view -h $FAMSEQ_OUTPUT > $FAMSEQ_MOD_OUTPUT # firstly change the header
sed -i 's|ID=GT\,|ID=OGT\,|g' $FAMSEQ_MOD_OUTPUT #
sed -i 's|ID=FGT\,|ID=GT\,|g' $FAMSEQ_MOD_OUTPUT #
numb_col=$(tail -n1 $FAMSEQ_MOD_OUTPUT | wc -w)
nsamp=$(($nbr_col-9))
#
FAMSEQ_MOD_TEMPO1="$TEMP_DIR/vcf_famseq_mod_temp.txt"
FAMSEQ_MOD_TEMPO2="$TEMP_DIR/vcf_famseq_mod_split_list1.txt"
FAMSEQ_MOD_TEMPO3="$TEMP_DIR/vcf_famseq_mod_split_list2.txt"
FAMSEQ_MOD_TEMPSPLIT_pref="vcf_famseq_mod_splittemp_"
FAMSEQ_MOD_TEMPSPLIT="$TEMP_DIR/$FAMSEQ_MOD_TEMPSPLIT_pref"
bcftools view -H $FAMSEQ_OUTPUT | grep "FGT" > $FAMSEQ_MOD_TEMPO1
bcftools view -H $FAMSEQ_OUTPUT | grep -v "FGT" >> $FAMSEQ_MOD_OUTPUT # put all the variants that were not changed by FamSeq to new output VCF - sort it later
split -n 23 -d $FAMSEQ_MOD_TEMPO1 $FAMSEQ_MOD_TEMPSPLIT  # split up the variants that were change by FamSeq
find $TEMP_DIR -name $FAMSEQ_MOD_TEMPSPLIT_pref"*" > $FAMSEQ_MOD_TEMPO2 #
sfile=$(wc -l $FAMSEQ_MOD_TEMPO2) # get number of splits
#
while read line;     # do while there are lines from input file
do #
	bash dv-trio_famseq_finalise.sh $line &
done < $FAMSEQ_MOD_TEMPO2  #
#
for i in {1..30} # check for 5 hrs max
do 
 find $TEMP_DIR -name $FAMSEQ_MOD_TEMPSPLIT_pref"*_done.txt" > $FAMSEQ_MOD_TEMPO3 
 nfile=$(wc -l $FAMSEQ_MOD_TEMPO3)
 if [ "$nfile" == "$sfile" ];
 then
	famseq_complete=true
	break
 else
	sleep 10m #
 fi
done
#
while read line;     # do while there are lines from input file
do #
	cat $line >> $FAMSEQ_MOD_OUTPUT #
done < $FAMSEQ_MOD_TEMPO3  #
#
##################
echo -e "OUT\t$FAMSEQ_OUTPUT" > $FAMSEQ_DIR/famseq_done.txt
echo "$(date) - FamSeq completed"

