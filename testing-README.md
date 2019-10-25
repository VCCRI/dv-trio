
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
#
bash dv-trio.sh -i GIAB_trio_file.txt \  
-r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna \  
-o GIAB_output  

## Create dv-trio-gatk trio 
#
This file is created as part of the dv-trio process. This file is located in the co_calling directory within the dv-trio output directory.
The file is named "trio_co_called.vcf.gz" 

Using variant tool set (vt) to decompose/block substitutions/normalization of multi-allelic variants ( git clone https://github.com/atks/vt.git )  

1. vt decompose -o output_D.vcf -s trio_co_called.vcf.gz  
2. vt decompose_blocksub -o output_DB.vcf -a output_D.vcf  
3. vt normalize -r GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o trio_co_called_DBN.vcf output_DB.vcf  

Final output of dv-trio-gatk trio is trio_co_called_DBN.vcf  

## Create dv-trio-bcftools trio 
#
using the VCF files created as part of the dv-trio process. Each sample's VCF are located in their own sample named directory within the deepvariant directory.
eg for HG002, it would located at deepvariant/HG002/output/HG002.output.vcf.gz

Pre-processing of the individual samples VCF - repeat for each sample (HG002/HG003/HG004):  

1. vt decompose -o HG002_D.vcf -s HG002.output.vcf.gz  
2. vt decompose_blocksub -o HG002_DB.vcf -a HG002_D.vcf  
3. vt normalize -r GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o HG002_DBN.vcf HG002_DB.vcf  

Merge samples VCF to create a family-trio VCF:  

4. bcftools merge -0 -m none -O v -o GIAB-family-dv-bcftools.vcf HG002_DBN.vcf HG003_DBN.vcf HG004_DBN.vcf  

Post-processing of the family-trio VCF:  

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
#
....

## Perform mendelelian error test using akt mendel 
#
Mendel Error Rate : akt - ancestry and kinship toolkit (v0.2.0) ([https://github.com/Illumina/akt](https://github.com/Illumina/akt))  
#
bcftools convert -o GIAB.bcf -O b GIAB_dv-trio.vcf.gz  
akt mendel GIAB.bcf -p GIAB.ped > GIAB_mendel.txt  

## Preform precision, Recall and F1-score calculation using hap.py 
#
F1 score, recall and precision :  Haplotype Comparsion Tools ([https://github.com/Illumina/hap.py](https://github.com/Illumina/hap.py))  
#


