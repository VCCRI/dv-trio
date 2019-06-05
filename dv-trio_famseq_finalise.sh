#!/bin/bash
# dv-trio.sh
input=$1 #
output=$1".txt" #
#save original GT value and move Famseq GT to be the GT value for sample
while read line;     # do while there are lines from input file
do #
 read -d '\t' -r -a line_fields  <<< "$line" #
 IFS=': ' read -r -a format_fields  <<< "${line_fields[8]}" #
 IFS=': ' read -r -a samp1_fields  <<< "${line_fields[9]}" #
 IFS=': ' read -r -a samp2_fields  <<< "${line_fields[10]}" #
 IFS=': ' read -r -a samp3_fields  <<< "${line_fields[11]}" #
 arr_len=${#format_fields[@]} # how many FORMAT fields for this variant
 len=$(($arr_len-1))
 #
 format_redo=""
 sample1_redo=""
 sample2_redo=""
 sample3_redo=""
 FGT_found=false 
 #
 for (( i=0; i<=$len; i++ )); # for the number of format fields in this variant line
 do 
	if [ ${format_fields[$i]} == "FGT" ]; # find the famseq GT field
	then #
		FGT_nbr=$i
		FGT_found=true # yes
	else # not this format field
		format_redo=$format_redo":"${format_fields[$i]} # save it
		sample1_redo=$sample1_redo":"${samp1_fields[$i]}
		sample2_redo=$sample2_redo":"${samp2_fields[$i]}
		sample3_redo=$sample3_redo":"${samp3_fields[$i]}
		#
	fi
	
 done #
 #echo $FGT_nbr
 #
 if [ "$FGT_found" = true ]; # if a FGT field found then move it to the front of the line for FORMAT fields, which is a VCF requirement
 then
	format_redo=${format_fields[$FGT_nbr]}$format_redo
	sample1_redo=${samp1_fields[$FGT_nbr]}$sample1_redo
	sample2_redo=${samp2_fields[$FGT_nbr]}$sample2_redo
	sample3_redo=${samp3_fields[$FGT_nbr]}$sample3_redo
 else # no FGT, which means it is a indel, then just use original
	format_redo=${line_fields[8]}
	sample1_redo=${line_fields[9]}
	sample2_redo=${line_fields[10]}
	sample3_redo=${line_fields[11]}
 fi
 #
 tab="\t"
 base="" 
 for (( i=0; i<8; i++ )); 
 do 
	base=$base${line_fields[$i]}$tab # build the front part of the variant line, which has no change
 done
 #
 echo -e $base$format_redo$tab$sample1_redo$tab$sample2_redo$tab$sample3_redo | sed -e 's/:GT:/:OGT:/g' -e 's/FGT:/GT:/g' >> $output # put new variant line with the GT and FGt reordered
done < $input # 
#
echo -e "OUT\t$input" > $input".done" 

#
