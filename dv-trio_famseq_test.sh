#!/bin/bash
# dv-trio.sh
echo "Running FamSeq..."
TEMP_DIR="/home/ubuntu/famseq_work/temp"
mkdir -p "${TEMP_DIR}"
FAMSEQ_OUTPUT="/home/ubuntu/famseq_work/GIAB_corr_1.0_famseq1.vcf"
FAMSEQ_MOD_OUTPUT="/home/ubuntu/famseq_work/trio.FamSeq_mod.vcf"
FAMSEQ_MOD_TEMPO1="$TEMP_DIR/vcf_famseq_mod_temp.txt"
FAMSEQ_MOD_TEMPO2="$TEMP_DIR/vcf_famseq_mod_split_list1.txt"
FAMSEQ_MOD_TEMPO3="$TEMP_DIR/vcf_famseq_mod_split_list2.txt"
FAMSEQ_MOD_TEMPVCF="$TEMP_DIR/vcf_famseq_mod_temp.vcf"
FAMSEQ_MOD_TEMPSPLIT_pref="vcf_famseq_mod_splittemp_"
FAMSEQ_MOD_TEMPSPLIT="$TEMP_DIR/$FAMSEQ_MOD_TEMPSPLIT_pref"
#save original GT value and move Famseq GT to be the GT value for sample
bcftools view -h $FAMSEQ_OUTPUT > $FAMSEQ_MOD_TEMPVCF # firstly change the header
sed -i 's|ID=GT\,|ID=OGT\,|g' $FAMSEQ_MOD_TEMPVCF #
sed -i 's|ID=FGT\,|ID=GT\,|g' $FAMSEQ_MOD_TEMPVCF #
numb_col=$(tail -n1 $FAMSEQ_MOD_OUTPUT | wc -w)
nsamp=$(($nbr_col-9))
#
FAMSEQ_MOD_TEMPO1="$TEMP_DIR/vcf_famseq_mod_temp.txt"
FAMSEQ_MOD_TEMPO2="$TEMP_DIR/vcf_famseq_mod_split_list1.txt"
FAMSEQ_MOD_TEMPO3="$TEMP_DIR/vcf_famseq_mod_split_list2.txt"
FAMSEQ_MOD_TEMPVCF="$TEMP_DIR/vcf_famseq_mod_temp.vcf"
FAMSEQ_MOD_TEMPSPLIT_pref="vcf_famseq_mod_splittemp_"
FAMSEQ_MOD_TEMPSPLIT="$TEMP_DIR/$FAMSEQ_MOD_TEMPSPLIT_pref"
bcftools view -H $FAMSEQ_OUTPUT | grep "FGT" > $FAMSEQ_MOD_TEMPO1
bcftools view -H $FAMSEQ_OUTPUT | grep -v "FGT" >> $FAMSEQ_MOD_TEMPVCF # put all the variants that were not changed by FamSeq to new output VCF - sort it later
split -n 23 -d $FAMSEQ_MOD_TEMPO1 $FAMSEQ_MOD_TEMPSPLIT  # split up the variants that were change by FamSeq
find $TEMP_DIR -name $FAMSEQ_MOD_TEMPSPLIT_pref"*" > $FAMSEQ_MOD_TEMPO2 #
sfile=$(wc -l $FAMSEQ_MOD_TEMPO2) # get number of splits
#
while read line;     # do while there are lines from input file
do #
	bash dv-trio_famseq_finalise.sh $line &
done < $FAMSEQ_MOD_TEMPO2  #
#
for i in {1..18} # check for 3 hrs max
do 
 find $TEMP_DIR -name $FAMSEQ_MOD_TEMPSPLIT_pref"*_done.txt" > $FAMSEQ_MOD_TEMPO3 
 nfile=$(wc -l $FAMSEQ_MOD_TEMPO3)
 if [ $nfile = $sfile ];
 then
	famseq_complete=true
	break
 else
	sleep 10m #
 fi
done
#
find $TEMP_DIR -name $FAMSEQ_MOD_TEMPSPLIT_pref"*.txt" > $FAMSEQ_MOD_TEMPO3 
while read line;     # do while there are lines from input file
do #
	cat $line >> $FAMSEQ_MOD_OUTPUT #
done < $FAMSEQ_MOD_TEMPO3  #
#
bcftools sort -o $FAMSEQ_MOD_OUTPUT -O V -T $TEMP_DIR #
##################
echo -e "OUT\t$FAMSEQ_OUTPUT" > $FAMSEQ_DIR/famseq_done.txt
echo "$(date) - FamSeq completed"

