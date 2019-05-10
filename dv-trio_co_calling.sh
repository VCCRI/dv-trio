#!/bin/bash
# dv-trio.sh
#
input=$1 #
# Initialise variables
child_input_gvcf=''
father_input_gvcf=''
mother_input_gvcf=''
ref=''
outdir=''
#
s1_p=false
s2_p=false
s3_p=false

# check the input file to see if it contain all samples details
echo "$(date) - Trio co_calling started."
echo "input file : "$input
while read line;     # do while there are lines from input file
do #
 read s_type other  <<< "$line" #
 read -d '\t' -r -a sample_val  <<< "$line" #
 if [ $s_type == "GVCF" ]; #
 then #
	if [ "$s1_p" = false ]; #
	then #
		child_input_gvcf=${sample_val[1]}
		s1_p=true
	elif [ "$s2_p" = false ]; #
	then #
		father_input_gvcf=${sample_val[1]}
		s2_p=true
	elif [ "$s3_p" = false ]; #
	then #
		mother_input_gvcf=${sample_val[1]}
		s3_p=true
	fi
 elif [ $s_type == "REF" ]; # 
 then # No
	ref=${sample_val[1]}
 elif [ $s_type == "OUT" ]; # 
 then # No
	COCALL_DIR=${sample_val[1]}
fi #
done < $input # 
#
echo "child : $child_input_gvcf" #
echo "father : $father_input_gvcf" #
echo "mother : $mother_input_gvcf" #
#
#COCALL_DIR="${absolute_outdir}/co_calling"
TEMP_DIR="${COCALL_DIR}/temp"
#
#mkdir -p "${COCALL_DIR}"
mkdir -p "${TEMP_DIR}"
#
child_gvcf="${TEMP_DIR}/child.output.cvd.g.vcf.gz"
father_gvcf="${TEMP_DIR}/father.output.cvd.g.vcf.gz"
mother_gvcf="${TEMP_DIR}/mother.output.cvd.g.vcf.gz"
#
#convert deepvariant gvcf files into format that GATK can use
#
zcat $child_input_gvcf | sed 's/<\*>/<NON_REF\>/g' | bgzip -c > $child_gvcf #
tabix -p vcf $child_gvcf #
#
zcat $father_input_gvcf | sed 's/<\*>/<NON_REF\>/g' | bgzip -c > $father_gvcf #
tabix -p vcf $father_gvcf #
#
zcat $mother_input_gvcf | sed 's/<\*>/<NON_REF\>/g' | bgzip -c > $mother_gvcf #
tabix -p vcf $mother_gvcf #
#
#
# create a merged gVCF
#
merge_gvcf="${TEMP_DIR}/merge_gvcf.g.vcf.gz"
#
gatk-4.1.2.0/gatk --java-options "-Xmx12g -Djava.io.tmpdir=$TEMP_DIR" CombineGVCFs \
-R $ref \
--variant $child_gvcf \
--variant $father_gvcf \
--variant $mother_gvcf \
-O $merge_gvcf
#
tabix -p vcf $merge_gvcf
#
# call variants from merged gVCF
#
co_called_vcf="${COCALL_DIR}/trio_co_called.vcf.gz"
#
gatk-4.1.2.0/gatk --java-options "-Xmx12g -Djava.io.tmpdir=$PBS_JOBFS" GenotypeGVCFs \
-R $ref \
-V $merge_gvcf \
-O $co_called_vcf
#
tabix -p vcf $co_called_vcf
#
#clean up
#
#rm -rf $TEMP_DIR #
#
echo "$(date) - Trio co_calling completed."
#
#touch $COCALL_DIR/trio_co_called_done.txt #
echo -e "CCALL\t$co_called_vcf" > $COCALL_DIR/trio_co_called_done.txt
#