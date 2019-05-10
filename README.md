
# dv-trio

dv-trio provides a pipeline to call variants for a trio (father-mother-child) using DeepVariants [1]. Genomic Variant Calling Files (gVCFs) created by DeepVariants are then co_called together using GATK[2]. The resultant trio VCF is then post-processing with FamSeq[3] to eliminate mendelian errors.

## Installation
Clone this repository into your cloud instance and run the `install_dependencies.sh` script. This will install all dependencies onto your instance's PATH.

## Usage
```
Usage:
       dv-trio.sh -i <input parameter file> -r <reference> [ -o <output directory name> ] [ -t <threshold> ] [ -b <bucket> ]

Post-processes trio calls made by DeepVariant to correct for Mendelian errors.

Required arguments:

  -i <input parameter file>   path to input file contain trio details. 
                              See input file creation section below for details
  -r <reference>              path to reference file. 
                              The directory holding the reference file need to contain the fa, fai and dict files

Options:
  -o <output>     path to desired output directory (defaults to current directory)
  -t <threshold>  likelihood ratio cutoff threshold (float b/w 0 and 1, default is 1.0)
  -b <bucket>     S3 bucket path to write output to
  -h              this help message
```
## Input Parameter File
A **tab delimited** text file contains details regarding the trio samples

 - Sample ID
 - Sample Bam location 
 - Sample Gender (1 - male, 2 - female)

#Sample	&nbsp;Sample_ID &nbsp;	Sample_bam_location &nbsp;Sample_gender  
CHILD&nbsp;&nbsp;HG002 &nbsp;/home/ubuntu/GIAB_bams/HG002.GRCh38.60x.1.RG.bam &nbsp;1  
FATHER&nbsp;HG003 &nbsp;/home/ubuntu/GIAB_bams/HG003.GRCh38.60x.1.RG.bam &nbsp;1  
MOTHER&nbsp;HG004 &nbsp;/home/ubuntu/GIAB_bams/HG004.GRCh38.60x.1.RG.bam &nbsp;2  
#Sample	Sample_ID	Sample_bam_location	Sample_gender  
CHILD	HG002	/home/ubuntu/GIAB_bams/HG002.GRCh38.60x.1.RG.bam	1  
FATHER	HG003	/home/ubuntu/GIAB_bams/HG003.GRCh38.60x.1.RG.bam	1  
MOTHER	HG004	/home/ubuntu/GIAB_bams/HG004.GRCh38.60x.1.RG.bam	2  

See template input file GIAB_trio_file.txt

## Cloud instance recommendation
We were able to successfully run dv-trio for a WGS trio under the following machine condition.

Samples : Genome in a Bottle Consortium's AshkenazimTrio - HG002/HG003/HG004  
Virtual Machine :  **AWS** - Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - 64-bit (x86)  
Instance Type : Compute Optimized - C5.9xlarge - 36 vCPUs, 72GB Memory  
Instance Storage : 1000GB (at least two times the size of the bam files size)   

## References 

 1. R. Poplin, P.-C. Chang, D. Alexander, S. Schwartz, T. Colthurst, A. Ku, D. Newburger,
J. Dijamco, N. Nguyen, P. T. Afshar, et al. A universal snp and small-indel
variant caller using deep neural networks. Nature biotechnology, 2018.
 
 2. M. A. DePristo, E. Banks, R. Poplin, K. V. Garimella, J. R. Maguire, C. Hartl, A. A.
Philippakis, G. Del Angel, M. A. Rivas, M. Hanna, et al. A framework for variation
discovery and genotyping using next-generation dna sequencing data. Nature genetics,
43(5):491–498, 2011. 
 3. G. Peng, Y. Fan, and W. Wang. Famseq: a variant calling program for familybased
sequencing data using graphics processing units. PLoS computational biology,
10(10):e1003880, 2014.
