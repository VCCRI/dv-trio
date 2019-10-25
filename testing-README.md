
# dv-trio - testing outline from application note

### Test Data :

### GIAB Ashkenazim Trio data files - 

**BAMs :**  
HG002 (proband - son) - ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/AshkenazimTrio/HG002_NA24385_son/NIST_HiSeq_HG002_Homogeneity-10953946/NHGRI_Illumina300X_AJtrio_novoalign_bams/HG002.GRCh38.60x.1.bam  
HG003 (father) - ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/AshkenazimTrio/HG003_NA24149_father/NIST_HiSeq_HG003_Homogeneity-12389378/NHGRI_Illumina300X_AJtrio_novoalign_bams/HG003.GRCh38.60x.1.bam  
HG004 (mother) - ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/AshkenazimTrio/HG004_NA24143_mother/NIST_HiSeq_HG004_Homogeneity-14572558/NHGRI_Illumina300X_AJtrio_novoalign_bams/HG004.GRCh38.60x.1.bam  

**Gold Standard Trurth dataset :**  
HG002 (proband - son) - ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/release/AshkenazimTrio/HG002_NA24385_son/latest/GRCh38/  
HG003 (father) - ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/release/AshkenazimTrio/HG003_NA24149_father/latest/GRCh38/  
HG004 (mother) - ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/release/AshkenazimTrio/HG004_NA24143_mother/latest/GRCh38/  

**Reference :**  
GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna  
GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna.fai  

**Pedigree :**   
Family Subject Father Mother Sex Phenotype  
GIAB	HG002	HG003	HG004	1	1  
GIAB	HG003	0		0		1	1  
GIAB	HG004	0		0		2	1  

### 1000 Genomes Project CEPH Trio genome data files - 
**CRAMs :**  
NA12878 (proband - daughter) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12878/alignment/NA12878.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  
NA12891 (father) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12891/alignment/NA12891.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  
NA12892 (mother) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12892/alignment/NA12892.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram    

**Reference :**  
GRCh38_full_analysis_set_plus_decoy_hla.fa  
GRCh38_full_analysis_set_plus_decoy_hla.fa.fai  

**Pedigree :**  
Family Subject Father Mother Sex Phenotype   
NA12878	NA12878	NA12891	NA12892	2	2   
NA12878	NA12891	0		0		1	1   
NA12878	NA12892	0		0		2	1   

### 1000 Genomes Project CEPH Trio exome data files - 
**BAMs :**  
NA12878 (proband - daughter) - ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20120117_ceu_trio_b37_decoy/CEUTrio.HiSeq.WEx.b37_decoy.NA12878.clean.dedup.recal.20120117.bam  
ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20120117_ceu_trio_b37_decoy/CEUTrio.HiSeq.WEx.b37_decoy.NA12878.clean.dedup.recal.20120117.bam.bai  
NA12891 (father) - ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20120117_ceu_trio_b37_decoy/CEUTrio.HiSeq.WEx.b37_decoy.NA12891.clean.dedup.recal.20120117.bam  
ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20120117_ceu_trio_b37_decoy/CEUTrio.HiSeq.WEx.b37_decoy.NA12891.clean.dedup.recal.20120117.bam.bai  
NA12892 (mother) - ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20120117_ceu_trio_b37_decoy/CEUTrio.HiSeq.WEx.b37_decoy.NA12892.clean.dedup.recal.20120117.bam  
ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20120117_ceu_trio_b37_decoy/CEUTrio.HiSeq.WEx.b37_decoy.NA12892.clean.dedup.recal.20120117.bam.bai  

**Reference :**  
ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37_decoy.fasta.gz  
ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/b37/human_g1k_v37_decoy.fasta.fai.gz  


## Create dv-trio trio - using GIAB AKT trio 

bash dv-trio.sh -i GIAB_trio_file.txt \  
-r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna \  
-o GIAB_output  

## Create dv-trio-gatk trio 

This file is created as part of the dv-trio process. This file is located in the co_calling directory within the dv-trio output directory.
The file is named "trio_co_called.vcf.gz" 

Using variant tool set (vt) to decompose/block substitutions/normalization of multi-allelic variants ( git clone https://github.com/atks/vt.git )  

1. vt decompose -o output_D.vcf -s trio_co_called.vcf.gz  
2. vt decompose_blocksub -o output_DB.vcf -a output_D.vcf  
3. vt normalize -r GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o trio_co_called_DBN.vcf output_DB.vcf  

Final output of dv-trio-gatk trio is trio_co_called_DBN.vcf  

## Create dv-trio-bcftools trio 

using the VCF files created as part of the dv-trio process. Each sample's VCF are located in their own sample named directory within the deepvariant directory.
eg for HG002, it would located at deepvariant/HG002/output/HG002.output.vcf.gz

**Pre-processing of the individual samples VCF - repeat for each sample (HG002/HG003/HG004):**  

1. vt decompose -o HG002_D.vcf -s HG002.output.vcf.gz  
2. vt decompose_blocksub -o HG002_DB.vcf -a HG002_D.vcf  
3. vt normalize -r GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o HG002_DBN.vcf HG002_DB.vcf  

**Merge samples VCF to create a family-trio VCF:**  

4. bcftools merge -0 -m none -O v -o GIAB-family-dv-bcftools.vcf HG002_DBN.vcf HG003_DBN.vcf HG004_DBN.vcf  

**Post-processing of the family-trio VCF:**  

5. vt decompose -o GIAB-family-dv-bcftools_D.vcf -s GIAB-family-dv-bcftools.vcf  
6. vt decompose_blocksub -o GIAB-family-dv-bcftools_DB.vcf -a GIAB-family-dv-bcftools_D.vcf  
7. vt normalize -r GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o GIAB-family-dv-bcftools_DBN.vcf GIAB-family-dv-bcftools_DB.vcf  
8. Remove all non-variant detail lines from family-trio VCF
gatk --java-options SelectVariants  \
-V GIAB-family-dv-bcftools_DBN.vcf \
-O GIAB-family-dv-bcftools-variants.vcf \
-sn "HG002" \
-sn "HG003" \
-sn "HG004" \
-remove-unused-alternates TRUE \
-exclude-non-variants TRUE 

Final output of dv-trio-bcftools trio is GIAB-family-dv-bcftools-variants.vcf  

## Create gatk4-bp trio 

**Apply BQSR on BAMs**  

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" BaseRecalibrator \
-R $ref \
-I $input_bam \
--known-sites "/home/ubuntu/CEPH-gatk/gatk-bundle/beta/Homo_sapiens_assembly38.dbsnp138.vcf.gz" \
--known-sites "/home/ubuntu/CEPH-gatk/gatk-bundle/beta/Homo_sapiens_assembly38.known_indels.vcf.gz" \
--known-sites "/home/ubuntu/CEPH-gatk/gatk-bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz" \
-O $bqsr_table

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" ApplyBQSR \
-R $ref \
-I $input_bam \
--bqsr-recal-file $bqsr_table \
-O $bqsr_bam
#
**Validate BQSR BAMs**

java -Xmx16g -Djava.io.tmpdir=$TEMP_DIR -jar  /home/ubuntu/dv-trio/picard.jar ValidateSamFile \
I=$bqsr_bam \
MODE=VERBOSE
#
**Call gVCF from BQSR BAMs**

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" HaplotypeCaller \
-R $ref \
-I $bqsr_bam \
-ERC GVCF \
-O $sample_gvcf 
#
**Validate gVCFs**

/home/ubuntu/dv-trio/gatk/gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" ValidateVariants \
-R $ref \
-V $sample_gvcf \
--validation-type-to-exclude ALLELES \
-gvcf
#
**Setup GATK GenomicDB**

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" GenomicsDBImport \
-V "child.g.vcf.gz" \
-V "father.g.vcf.gz" \
-V "mother.g.vcf.gz" \
-L 1 -L 2 -L 3 -L 4 -L 5 -L 6 -L 7 -L 8 -L 9 -L 10 -L 11 -L 12 -L 13 -L 14 -L 15 -L 16 -L 17 -L 18 -L 19 -L 20 -L 21 -L 22 -L X -L Y -L MT \
--genomicsdb-workspace-path "/gvcf/GDBI"
#
**Call trio VCF**

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" GenotypeGVCFs \
-R $ref \
-G StandardAnnotation \
-V gendb://"/gvcf/GDBI" \
--tmp-dir="/temp/" \
-O "gatk4-bp-co_called.vcf.gz"
#
**Variant Quality Check of VCF**

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" VariantFiltration \
-R $ref \
--filter-expression "ExcessHet > 54.69" \
--filter-name ExcessHet \
-V "gatk4-bp-co_called.vcf.gz" \
-O "gatk4-bp-co_called.varFilt.vcf.gz"
#
**VQSR application on VCF**

gbundle="/home/ubuntu/CEPH-gatk/gatk-bundle"

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" VariantRecalibrator \
-V "gatk4-bp-co_called.varFilt.vcf.gz" \
--tranches-file "all_gatk4_output_INDEL.tranches" \
--rscript-file "all_gatk4_output_INDEL.plots.R" \
--trust-all-polymorphic  \
-tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
-an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
-mode INDEL  \
--max-gaussians 4 \
--resource:mills,known=false,training=true,truth=true,prior=12 "${gbundle}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz" \
--resource:axiomPoly,known=false,training=true,truth=true,prior=10 "${gbundle}/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz" \
--resource:dbsnp,known=true,training=false,truth=false,prior=2 "${gbundle}/beta/Homo_sapiens_assembly38.dbsnp138.vcf.gz" \
-O "gatk4-output-INDEL.recal"

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" VariantRecalibrator \
-V "gatk4-bp-co_called.varFilt.vcf.gz" \
--tranches-file "all_gatk4_output_SNP.tranches" \
--rscript-file "all_gatk4_output_SNP.plots.R" \
--trust-all-polymorphic \
-tranche 100.0 -tranche 99.95 -tranche 99.9 -tranche 99.8 -tranche 99.6 -tranche 99.5 -tranche 99.4 -tranche 99.3 -tranche 99.0 -tranche 98.0 -tranche 97.0 -tranche 90.0 \
-an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
-mode SNP \
--max-gaussians 6 \
--resource:hapmap,known=false,training=true,truth=true,prior=15 "${gbundle}/hapmap_3.3.hg38.vcf.gz" \
--resource:omni,known=false,training=true,truth=true,prior=12 "${gbundle}/1000G_omni2.5.hg38.vcf.gz" \
--resource:1000G,known=false,training=true,truth=false,prior=10 "${gbundle}/1000G_phase1.snps.high_confidence.hg38.vcf.gz" \
--resource:dbsnp,known=true,training=false,truth=false,prior=7 "${gbundle}/beta/Homo_sapiens_assembly38.dbsnp138.vcf.gz" \
-O "gatk4-output-SNP.recal"

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" ApplyVQSR \
-V "gatk4-bp-co_called.varFilt.vcf.gz" \
--recal-file "gatk4-output-INDEL.recal" \
--tranches-file "all_gatk4_output_INDEL.tranches" \
--truth-sensitivity-filter-level 99.7 \
--create-output-variant-index true \
-mode INDEL \
-O "gatk4-bp-co_called.varFilt.indel.vcf.gz"

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" ApplyVQSR \
-V "gatk4-bp-co_called.varFilt.indel.vcf.gz" \
--recal-file "gatk4-output-SNP.recal" \
--tranches-file "all_gatk4_output_SNP.tranches" \
--truth-sensitivity-filter-level 99.7 \
--create-output-variant-index true \
-mode SNP \
-O "gatk4-bp-co_called.varFilt.vqsr.vcf.gz"
#
**Validate final VCF**

gatk --java-options "-Xmx16g -Djava.io.tmpdir=$TEMP_DIR" ValidateVariants \
-R $ref \
-V "gatk4-bp-co_called.varFilt.vqsr.vcf.gz" \
--validation-type-to-exclude ALLELES 
#
## Perform mendelelian error test using akt mendel 

Mendel Error Rate : akt - ancestry and kinship toolkit (v0.2.0) ([https://github.com/Illumina/akt](https://github.com/Illumina/akt))  

bcftools convert -o GIAB.bcf -O b GIAB_dv-trio.vcf.gz  
akt mendel GIAB.bcf -p GIAB.ped > GIAB_mendel.txt  

## Preform precision, Recall and F1-score calculation using hap.py 

F1 score, recall and precision :  Haplotype Comparsion Tools ([https://github.com/Illumina/hap.py](https://github.com/Illumina/hap.py))  

#

