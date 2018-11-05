# dv-trio

dv-trio takes in a trio (father-mother-child) of bam files and calls variants using DeepVariant and a post-processing pipeline to eliminate mendelian errors.

## Installation
Clone this repository into your cloud instance and run the `install_dependencies.sh` script. This will install all dependencies onto your instance's PATH.

## Usage
```
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
```
