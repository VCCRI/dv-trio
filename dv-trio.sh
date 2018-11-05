#!/bin/bash
# dv-trio.sh

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
       $(basename $0) -f father -m mother -c child -s sex -r reference [ -o output ] [ -t threshold ] [ -b bucket ]

Post-processes trio calls made by DeepVariant to correct for Mendelian errors.

Required arguments:

  -f <father>     path to bam file of father sample
  -m <mother>     path to bam file of mother sample
  -c <child>      path to bam file of child sample
  -s <sex>        sex of child (m/f)
  -r <reference>  path to reference file

Options:
  -o <output>     path to desired output directory (defaults to current directory)
  -t <threshold>  likelihood ratio cutoff threshold (float b/w 0 and 1, default is 0.3)
  -b <bucket>     S3 bucket path to write output to
  -h              this help message
EOF

  exit $ec
}

# Initialise variables
father_path=''
mother_path=''
child_path=''
child_sex=''
ref=''
threshold='0.3'
outdir=$(dirname "$0")
upload_to_bucket=false
bucket=''

# Handle parameters
while getopts ':hf:m:c:s:r:o:t:' opt; do
  case "$opt" in 
    f) father_path="$OPTARG" ;;
    m) mother_path="$OPTARG" ;;
    c) child_path="$OPTARG" ;;
    s) child_sex="$OPTARG" ;;
    r) ref="$OPTARG" ;;

    o) 
        outdir="$OPTARG" 
        echo "getting outdir ${outdir}"
        ;;
    t) threshold="$OPTARG" ;;
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


Get sample names of samples
father_sample=`samtools view -H $father_path | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq`
mother_sample=`samtools view -H $mother_path | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq`
child_sample=`samtools view -H $child_path | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq`

running_dir=`pwd`
absolute_outdir=`pwd`/$outdir
echo $absolute_outdir

# DeepVariant Locations
BASE="${absolute_outdir}/deepvariant"
TEMP_DIR="${BASE}/temp"
OUTPUT_DIR="${BASE}/output"
MODELS_DIR="${BASE}/models"
LOG_DIR_BASE="${BASE}/logs"
REF="${running_dir}/$ref"

mkdir -p "${TEMP_DIR}"
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${MODELS_DIR}"
mkdir -p "${LOG_DIR_BASE}"

echo "${TEMP_DIR}"
echo "${OUTPUT_DIR}"
echo "${MODELS_DIR}"
echo "${LOG_DIR_BASE}"

BUCKET="gs://deepvariant"
BIN_VERSION="0.7.0"
MODEL_VERSION="0.7.0"
MODEL_BUCKET="${BUCKET}/models/DeepVariant/${MODEL_VERSION}/DeepVariant-inception_v3-${MODEL_VERSION}+data-wgs_standard"

N_SHARDS="4"

# Download model into MODEL_DIR
echo "Downloading model"
cd "${MODELS_DIR}"
gsutil -m cp -r "${MODEL_BUCKET}/*" .
echo "DOne downloading model"

# S3 bucket to store output
BUCKET_OUTPUT=bucket


cd "${BASE}"
samples=( $child_sample $father_sample $mother_sample )
bams=( $child_path $father_path $mother_path )
indices=( 0 1 2 )

for index in ${indices[@]}
do
    SAMPLE=${samples[$index]}
    BAM="${running_dir}/${bams[$index]}"

    echo "DOING ${SAMPLE} now from ${BAM}..."

    EXAMPLES="${TEMP_DIR}/${SAMPLE}.examples.tfrecord@${N_SHARDS}.gz"
    GVCF_TFRECORDS="${TEMP_DIR}/${SAMPLE}.gvcf.tfrecord@${N_SHARDS}.gz"
    CALL_VARIANTS_OUTPUT="${TEMP_DIR}/${SAMPLE}.cvo.tfrecord.gz"
    OUTPUT_VCF="${OUTPUT_DIR}/${SAMPLE}.output.vcf.gz"
    OUTPUT_GVCF="${OUTPUT_DIR}/${SAMPLE}.output.g.vcf.gz"
    LOG_DIR="${LOG_DIR_BASE}/${SAMPLE}"
    mkdir -p $LOG_DIR


    ####### ----------------------------- MAKE_EXAMPLES --------------------------------- #######

    echo "Running DeepVariant MAKE EXAMPLES..."

    # run make_examples
    cd "${BASE}"
    ( time seq 0 $((N_SHARDS-1)) | \
    parallel --halt 2 --joblog "${LOG_DIR}/log" --res "${LOG_DIR}" \
        sudo docker run \
        -v /home/${USER}:/home/${USER} \
        gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" \
        /opt/deepvariant/bin/make_examples \
        --mode calling \
        --ref "${REF}" \
        --reads "${BAM}" \
        --examples "${EXAMPLES}" \
        --sample_name "${SAMPLE}" \
        --task {} \
    ) >"${LOG_DIR}/make_examples_${SAMPLE}.log" 2>&1


    ####### ------------------------------ CALL_VARIANTS -------------------------------- #######

    echo "Running DeepVariant CALL VARIANTS..."

    # run call_variants
    cd "${BASE}"
    ( time sudo docker run \
        -v /home/${USER}:/home/${USER} \
        gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" \
        /opt/deepvariant/bin/call_variants \
        --outfile "${CALL_VARIANTS_OUTPUT}" \
        --examples "${EXAMPLES}" \
        --checkpoint "${MODEL}"
    ) >"${LOG_DIR}/call_variants_${SAMPLE}.log" 2>&1


    ####### ------------------------- POSTPROCESS_VARIANTS ---------------------------- #######

    echo "Running DeepVariant POSTPROCESS VARIANTS..."

    # run postprocess_variants
    cd "${BASE}"
    ( time sudo docker run \
        -v /home/${USER}:/home/${USER} \
        gcr.io/deepvariant-docker/deepvariant:"${BIN_VERSION}" \
        /opt/deepvariant/bin/postprocess_variants \
        --ref "${REF}" \
        --infile "${CALL_VARIANTS_OUTPUT}" \
        --outfile "${OUTPUT_VCF}"
    ) >"${LOG_DIR}/postprocess_variants_${SAMPLE}.log" 2>&1

done

echo "DeepVariant run completed."

# Write to S3 bucket
if [ upload_to_bucket = true ] ; then
    echo "Writing DeepVariant output to S3 Bucket"
    aws s3 cp "${OUTPUT_DIR}" s3://${BUCKET_OUTPUT}/DeepVariant/
    aws s3 cp "${LOG_DIR}" s3://${BUCKET_OUTPUT}/DeepVariant/
fi


# POSTPROCESING

echo "Starting postprocessing!"

# Postprocessing Locations
PP_BASE="${absolute_outdir}/postprocessing"
PP_TEMP_DIR="${PP_BASE}/temp"
PP_OUTPUT_DIR="${PP_BASE}/output"
PP_LOG_DIR="${PP_BASE}/logs"

temp="${outdir}/temp"
mkdir -p $PP_BASE
mkdir -p $PP_TEMP_DIR
mkdir -p $PP_OUTPUT_DIR
mkdir -p $PP_LOG_DIR

triple_name="${child_sample}_${father_sample}_${mother_sample}"

MERGED_VCF="${PP_TEMP_DIR}/${triple_name}.vcf"

father_vcf="${OUTPUT_DIR}/${father_sample}.output.vcf.gz"
mother_vcf="${OUTPUT_DIR}/${mother_sample}.output.vcf.gz"
child_vcf="${OUTPUT_DIR}/${child_sample}.output.vcf.gz"

zcat $father_vcf > "${PP_TEMP_DIR}/${father_sample}.output.vcf"
zcat $mother_vcf > "${PP_TEMP_DIR}/${mother_sample}.output.vcf"
zcat $child_vcf > "${PP_TEMP_DIR}/${child_sample}.output.vcf"

vcfs=( $child_sample $father_sample $mother_sample )

processed_vcfs_args=""

echo "Decomposing and normalising samples..."
# Decompose and normalise all vcfs
for i in ${vcfs[@]}
do
    vt decompose -s ${PP_TEMP_DIR}/${i}.output.vcf -o ${PP_TEMP_DIR}/${i}.dec.vcf 
    vt decompose_blocksub -a ${PP_TEMP_DIR}/${i}.dec.vcf -o ${PP_TEMP_DIR}/${i}.bs.vcf
    vt normalize ${PP_TEMP_DIR}/${i}.bs.vcf -r ${REF} | vt uniq - -o ${PP_TEMP_DIR}/${i}.processed.vcf
    bgzip ${PP_TEMP_DIR}/${i}.processed.vcf
    tabix -p vcf ${PP_TEMP_DIR}/${i}.processed.vcf.gz
    processed_vcfs_args+="${PP_TEMP_DIR}/${i}.processed.vcf.gz "
done

echo $processed_vcfs_args


echo "Generating pedigree file..."
# Generate pedigree file for FamSeq
ped_file="${PP_TEMP_DIR}/${triple_name}.ped"
touch $ped_file
cp /dev/null $ped_file

gender_num="2"
if [ $child_sex == "m" ] 
then
    gender_num="1"
fi

echo "ID  mID fID gender IndividualName" >> $ped_file
echo "1   3   2   ${gender_num}   ${child_sample}" >> $ped_file
echo "2   0   0   1   ${father_sample}" >> $ped_file
echo "3   0   0   2   ${mother_sample}" >> $ped_file


echo "Merging..."
# Merging
vcf-merge $processed_vcfs_args > ${MERGED_VCF}


echo "Running FamSeq..."
FAMSEQ_OUTPUT="${PP_OUTPUT_DIR}/${triple_name}.FamSeq.vcf"
FamSeq vcf -vcfFile $MERGED_VCF -pedFile $ped_file -output ${FAMSEQ_OUTPUT} -a -LRC ${threshold}
sed -i 's/[ \t]*$//' $FAMSEQ_OUTPUT

# Write to S3 bucket
if [ upload_to_bucket = true ] ; then
    echo "Writing Postprocessing output to S3 Bucket"
    aws s3 cp "${PP_OUTPUT_DIR}" s3://${BUCKET_OUTPUT}/dv-trio/
    aws s3 cp "${PP_LOG_DIR}" s3://${BUCKET_OUTPUT}/dv-trio/
fi

echo "All done!"
