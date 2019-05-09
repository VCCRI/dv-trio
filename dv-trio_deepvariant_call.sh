#!/bin/bash
# dv-trio.sh

# Initialise variables
s_type=''
s_id=''
s_bam=''
ref=''
outdir=''

# check the input file to see if it contain all samples details
echo "input file : "$1
echo "number of shards : "$2
while read line;     # do while there are lines from input file
do #
 read s_type other  <<< "$line" #
 read -d '\t' -r -a sample_val  <<< "$line" #
 if [ $s_type == "SAMPLE" ]; #
 then #
	s_id=${sample_val[1]}
	s_bam=${sample_val[2]}
 elif [ $s_type == "REF" ]; # 
 then # No
	ref=${sample_val[1]}
 elif [ $s_type == "OUT" ]; # 
 then # No
	absolute_outdir=${sample_val[1]}
fi #
done < $1 # 
#

#running_dir=`pwd`
#absolute_outdir=`pwd`/$outdir
echo "DV : "$absolute_outdir
#
export PATH=${PATH}:$HOME/gsutil
#
# DeepVariant Locations
BASE="${absolute_outdir}/deepvariant"
TEMP_DIR="${BASE}/temp"
OUTPUT_DIR="${BASE}/output"
MODELS_DIR="${BASE}/models"
MODEL="${MODELS_DIR}/model.ckpt"
LOG_DIR_BASE="${BASE}/logs"
REF="${running_dir}/$ref"

mkdir -p "${BASE}"
mkdir -p "${TEMP_DIR}"
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${MODELS_DIR}"
mkdir -p "${LOG_DIR_BASE}"

#echo "${TEMP_DIR}"
#echo "${OUTPUT_DIR}"
#echo "${MODELS_DIR}"
#echo "${LOG_DIR_BASE}"

BUCKET="gs://deepvariant"
BIN_VERSION="0.7.2"
MODEL_VERSION="0.7.2"
MODEL_BUCKET="${BUCKET}/models/DeepVariant/${MODEL_VERSION}/DeepVariant-inception_v3-${MODEL_VERSION}+data-wgs_standard"

N_SHARDS=$2

# Download model into MODEL_DIR
echo "Downloading model"
cd "${MODELS_DIR}"
gsutil -m cp -r "${MODEL_BUCKET}/*" .
echo "Done downloading model"

# S3 bucket to store output
#ed BUCKET_OUTPUT=bucket


cd "${BASE}"
SAMPLE=$s_id
BAM=$s_bam

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

echo "DeepVariant run completed for $s_id"
#touch $absolute_outdir/$s_id"_done.txt" #
echo -e "GVCF\t$OUTPUT_GVCF" > $absolute_outdir/$s_id"_done.txt"
#echo 

