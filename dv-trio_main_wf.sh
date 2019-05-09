#!/bin/bash
# dv-trio.sh

#
########################################################################################################
# FUNCTION USAGE: output info/help display. Also used when error in inputs
#
usage() {
  # this function prints a usage summary, optionally printing an error message
  local ec=0

  if [ $# -ge 2 ] ; then
    # if printing an error message, the first arg is the exit code, and
    # all remaining args are the message.
    ec="$1" ; shift
    printf "%s\n\n" "$*" >&2
  fi

  cat <<EOF
Usage:
       $(basename $0) -i <input parameters file> -r <reference> [ -o output ] [ -t threshold ] [ -b bucket ]

Post-processes trio calls made by DeepVariant to correct for Mendelian errors.

Required arguments:

  -i <input parameters file>     path to input parameter file containing trio bam path
  -r <reference>  path to reference file

Options:
  -o <output>     path to desired output directory (defaults to current directory)
  -t <threshold>  likelihood ratio cutoff threshold (float b/w 0 and 1, default is 0.3)
  -b <bucket>     S3 bucket path to write output to
  -h              this help message
EOF

  exit $ec
}
#
########################################################################################################
# FUNCTION CHECK_INPUT: check the input file to see if it contain all samples details
#
check_input ()
{ #
 while read line;     # do while there are lines from input file
 do #
  read s_type other  <<< "$line" #
  if [ $s_type == "CHILD" ]; #
  then #
	read -d '\t' -r -a child  <<< "$line" #
	child_given=true
	echo "${child[@]}"
  elif [ $s_type == "FATHER" ]; # 
  then # No
	read -d '\t' -r -a father  <<< "$line" #
	father_given=true
	echo "${father[@]}"
  elif [ $s_type == "MOTHER" ]; # 
  then # No
	read -d '\t' -r -a mother  <<< "$line" #
	mother_given=true
	echo "${mother[@]}"
  fi #
 done < $input_file # 
#
# check if trio required parameters given
 if [ "$child_given" = false ]; #
 then #
	usage 1 "child sample details required" 
	exit
 elif [ "$father_given" = false ]; #
 then #
	usage 1 "father sample details required" 
	exit
 elif [ "$mother_given" = false ]; #
 then #
	usage 1 "father sample details required" 
	exit
 fi #
}
#
########################################################################################################
# FUNCTION CALL_DEEPVARIANT: 
##
call_deepvariant ()
{ #
#create the input files for each sample to Deepvariant calling
#
 echo $outdir
 child_dir="$outdir/${child[1]}"
 father_dir="$outdir/${father[1]}"
 mother_dir="$outdir/${mother[1]}"
 echo "child dir : "$child_dir
 echo "father dir : "$father_dir
 echo "mother dir : "$mother_dir
#
 samples=( $child_dir $father_dir $mother_dir )
 IDs=(${child[1]} ${father[1]} ${mother[1]})
 bams=(${child[2]} ${father[2]} ${mother[2]})
 genders=(${child[3]} ${father[3]} ${mother[3]})
 indices=( 0 1 2 )
#
 for index in ${indices[@]}
 do
	create_dir=${samples[$index]}
	mkdir -p $create_dir
#	touch $create_dir/sample.txt
	echo -e "OUT\t$create_dir" > $create_dir/sample.txt
	echo -e "REF\t$ref" >> $create_dir/sample.txt
	echo -e "SAMPLE\t${IDs[$index]}\t${bams[$index]}\t${genders[$index]}" >> $create_dir/sample.txt
 done
#
# Do deepvariant variant calling
 echo "DeepVariant calling for ${father[1]} kicked off in background"
 #bash dv-trio_deepvariant_call.sh $father_dir/sample.txt &
 #sleep 30m #
#
 echo "DeepVariant calling for ${mother[1]} kicked off in background"
 #bash dv-trio_deepvariant_call.sh $mother_dir/sample.txt &
 #sleep 30m #
#
 echo "DeepVariant calling for ${child[1]}"
 #bash dv-trio_deepvariant_call.sh $child_dir/sample.txt 
#
# check if mother and father deepvariant call completed
#
 father_complete=false
 mother_complete=false
#
# check father
 for i in {1..30} # check for 5 hrs max
 do 
	if [ -f $father_dir/${father[1]}"_done.txt" ]; # check if father done
	then
		father_complete=true
		break
	else
		sleep 10m #
	fi
 done
 if [ "$father_complete" = false ]; #
 then #
	usage 1 "father sample did not complete deepvariant" 
	exit
 fi
 # check mother
 for i in {1..30} # check for 5 hrs max
 do 
	if [ -f $mother_dir/${mother[1]}"_done.txt" ]; # check if mother done
	then
		mother_complete=true
		break
	else
		sleep 10m #
	fi
 done
 if [ "$mother_complete" = false ]; #
 then #
	usage 1 "mother sample did not complete deepvariant" 
	exit
 fi #
#
}
#
########################################################################################################
# FUNCTION CALL_DEEPVARIANT: do GATK4 co_calling of gVCFs for trio
##
call_gatk_co_calling ()
{ #
#
#build input file to co_calling task
 #touch $co_call_dir/trio.txt
 echo -e "OUT\t$co_call_dir" > $co_call_dir/trio.txt
 echo -e "REF\t$ref" >> $co_call_dir/trio.txt
 cat $child_dir/${child[1]}"_done.txt" >> $co_call_dir/trio.txt
 cat $father_dir/${father[1]}"_done.txt" >> $co_call_dir/trio.txt
 cat $mother_dir/${mother[1]}"_done.txt" >> $co_call_dir/trio.txt
#
 bash dv-trio_co_calling.sh $co_call_dir/trio.txt #
#
}
#
########################################################################################################
# FUNCTION CALL_FAMSEQ: do FamSeq on co_call VCF for trio
##
call_famseq ()
{ #
#
 #touch $famseq_dir/famseq_trio.txt
#build famseq ped file
 ped_file=$famseq_dir/famseq_trio.ped
 #touch $ped_file

 echo -e "ID\tmID\tfID\tgender\tIndividualName" > $ped_file
 echo -e "1\t3\t2\t${child[3]}\t${child[1]}" >> $ped_file
 echo -e "2\t0\t0\t1\t${father[1]}" >> $ped_file
 echo -e "3\t0\t0\t2\t${mother[1]}" >> $ped_file
#
# build famseq input file
 #touch $famseq_dir/famseq_trio.txt
 echo -e "OUT\t$famseq_dir" > $famseq_dir/famseq_trio.txt
 echo -e "REF\t$ref" >> $famseq_dir/famseq_trio.txt
 echo -e "THOLD\t$Famseq_threshold" >> $famseq_dir/famseq_trio.txt
 echo -e "PED\t$ped_file" >> $famseq_dir/famseq_trio.txt
 cat $co_call_dir/trio_co_called_done.txt >> $famseq_dir/famseq_trio.txt
#
 bash dv-trio_famseq.sh $famseq_dir/famseq_trio.txt #
}
#
###########################################################################################
# MAIN
###########################################################################################
# Initialise variables
#
input_given=false
ref_given=false
father_given=false
mother_given=false
child_given=false
mother_path=''
child_path=''
child_sex=''
ref=''
outdir=`pwd`
Famseq_threshold='1.0'
run_function='3'
upload_to_bucket=false
bucket=''

# Handle parameters
while getopts ':hi:r:o:t:b:f:' opt; do
  case "$opt" in 
    i)
		input_file="$OPTARG" 
		input_given=true
		;;
    r)
		ref="$OPTARG" 
		ref_given=true;;
    f)
		run_function="$OPTARG" ;;

    o) 
        outdir="$OPTARG" 
        echo "getting outdir ${outdir}"
        ;;
    t) Famseq_threshold="$OPTARG" ;;
    b)
        bucket="$OPTARG"
        upload_to_bucket=true
        ;;

    h) usage ;;
    :) 
        usage 1 "-$OPTARG requires an argument" 
        exit
        ;;
    ?) 
        usage 1 "Unknown option '$opt'" 
        exit
        ;;
  esac
done

shift $((OPTIND -1))
# check if all required parameters given
if [ "$input_given" = false ]; #
then #
	usage 1 "-i requires an argument" 
	exit
elif [ "$ref_given" = false ]; #
then #
	usage 1 "-r requires an argument" 
	exit
fi #
#
check_input # check the input file
#
if [ "$run_function" -gt "0" ]; #
then #
	call_deepvariant # do deepvariant variant calling on the trio samples
fi
#
if [ "$run_function" -gt "1" ]; #
then #
	co_call_dir="$outdir/co_calling"
	mkdir -p $co_call_dir
	call_gatk_co_calling # do GATK call for co_calling of trio from gVCFs
fi
#
if [ "$run_function" -gt "2" ]; #
then #
	famseq_dir="$outdir/famseq"
	mkdir -p $famseq_dir
	call_famseq # do FamSeq call for mendelian error correction for trio VCF
fi #

