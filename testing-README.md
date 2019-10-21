
# dv-trio - testing outline from application note

## Cloud instance recommendation
We were able to successfully run dv-trio for a WGS trio under the following machine condition.

Samples : Genome in a Bottle Consortium's AshkenazimTrio - HG002/HG003/HG004  
Virtual Machine :  **AWS** - Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - 64-bit (x86)  
Instance Type : Compute Optimized - C5.9xlarge - 36 vCPUs, 72GB Memory  
Instance Storage : 1000GB (at least two times the size of the bam files size)   

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

### 1000 Genomes Project CEPH Trio genome data files - 
**CRAMs :**  
NA12878 (proband - daughter) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12878/alignment/NA12878.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  
NA12891 (father) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12891/alignment/NA12891.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  
NA12892 (mother) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12892/alignment/NA12892.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  

**Reference :**  
GRCh38_full_analysis_set_plus_decoy_hla.fa
GRCh38_full_analysis_set_plus_decoy_hla.fa.fai

### 1000 Genomes Project CEPH Trio exome data files - 
**CRAMs :**  
NA12878 (proband - daughter) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12878/alignment/NA12878.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  
NA12891 (father) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12891/alignment/NA12891.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  
NA12892 (mother) - ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/data/CEU/NA12892/alignment/NA12892.alt_bwamem_GRCh38DH.20150706.CEU.illumina_platinum_ped.cram  

**Reference :**  
human_g1k_v37_decoy.fasta
human_g1k_v37_decoy.fasta.fai

### Benchmarking Softwares :

Mendel Error Rate : akt - ancestry and kinship toolkit (v0.2.0) ([https://github.com/Illumina/akt](https://github.com/Illumina/akt))  
F1 score, recall and precision :  Haplotype Comparsion Tools ([https://github.com/Illumina/hap.py](https://github.com/Illumina/hap.py))  

## Create dv-trio trio 
#
bash dv-trio.sh -i GIAB_trio_file.txt -r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o GIAB_output 

## Create dv-trio-gatk trio 
#
bash dv-trio.sh -i GIAB_trio_file.txt -r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o GIAB_output 

## Create dv-trio-bcftools trio 
#
bash dv-trio.sh -i GIAB_trio_file.txt -r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o GIAB_output 

## Create gatk4-bp trio 
#
bash dv-trio.sh -i GIAB_trio_file.txt -r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o GIAB_output 

## Perform mendelelian error test using akt mendel 
#
bash dv-trio.sh -i GIAB_trio_file.txt -r /home/ubuntu/ref/GCA_000001405.15_GRCh38_no_alt_plus_hs38d1_analysis_set.fna -o GIAB_output 


