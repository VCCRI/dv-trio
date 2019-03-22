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


#Get sample names of samples
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
MODEL="${MODELS_DIR}/model.ckpt"
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
BIN_VERSION="0.7.2"
MODEL_VERSION="0.7.2"
MODEL_BUCKET="${BUCKET}/models/DeepVariant/${MODEL_VERSION}/DeepVariant-inception_v3-${MODEL_VERSION}+data-wgs_standard"

N_SHARDS="4"

# Download model into MODEL_DIR
echo "Downloading model"
cd "${MODELS_DIR}"
gsutil -m cp -r "${MODEL_BUCKET}/*" .
echo "Done downloading model"

# S3 bucket to store output
BUCKET_OUTPUT=bucket


cd "${BASE}"
echo "${child_sample} : ${child_path} "
samples=( $child_sample )
bams=( $child_path )
indices=( 0 )
echo "Setup input samples"
#samples=( $child_sample $father_sample $mother_sample )
#bams=( $child_path $father_path $mother_path )
#indices=( 0 1 2 )

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
        --gvcf "${GVCF_TFRECORDS}" \
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
        --checkpoint "${MODEL}" \
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
        --outfile "${OUTPUT_VCF}" \
        --nonvariant_site_tfrecord_path "${GVCF_TFRECORDS}" \
        --gvcf_outfile "${OUTPUT_GVCF}" \
    ) >"${LOG_DIR}/postprocess_variants_${SAMPLE}.log" 2>&1

done

if [ upload_to_bucket = true ] ; then
    echo "Writing DeepVariant output to S3 Bucket"
    aws s3 cp "${OUTPUT_DIR}" s3://${BUCKET_OUTPUT}/DeepVariant/
    aws s3 cp "${LOG_DIR}" s3://${BUCKET_OUTPUT}/DeepVariant/
fi
echo "DeepVariant run completed."

