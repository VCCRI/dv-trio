#install

# gsutil

# curl https://sdk.cloud.google.com | bash
# exec -l $SHELL

mkdir -p lib
#
sudo snap install aws-cli --classic
sudo apt-get update -y
#sudo rm /boot/grub/menu.lst
#sudo update-grub-legacy-ec2 -y
#sudo apt-get dist-upgrade -qq --force-yes
#sudo apt upgrade -y
sudo apt install build-essential -y
#sudo apt install gcc
sudo apt install zlib1g-dev -y

sudo apt-get install libbz2-dev -y
sudo apt-get install liblzma-dev -y
#sudo apt install make
sudo apt-get install autoconf -y
sudo apt install pkg-config -y
sudo apt-get install libcurl4 libcurl4-openssl-dev -y
sudo apt-get install libssl-dev -y
sudo apt-get -y install docker.io

# htslib
wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2 -O htslib.tar.bz2
tar -xjvf htslib.tar.bz2
cd htslib-1.9
make
sudo make install
cd ..

# samtools
sudo apt-get -y install samtools
samtools help

# bcftools
wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2 -O bcftools.tar.bz2
tar -xjvf bcftools.tar.bz2
cd bcftools-1.9
make
sudo make prefix=/usr/local/bin install
sudo ln -s /usr/local/bin/bin/bcftools /usr/bin/bcftools
export BCFTOOLS_PLUGINS=`pwd`/plugins/
cd ..
bcftools help

# vcf-tools
git clone https://github.com/vcftools/vcftools.git
cd vcftools
./autogen.sh
./configure
make
sudo make install
export PERL5LIB=`pwd`/src/perl/
# sudo ln -s `pwd`/src/perl/vcf-merge /usr/bin/vcf-merge
cd ..
vcftools --version

# vt
git clone https://github.com/atks/vt.git  
cd vt
make
make test
sudo ln -s `pwd`/vt /usr/bin/vt
cd ..
vt help

# parallel
#sudo apt-get -y update
sudo apt-get -y install parallel

# FamSeq
wget http://bioinformatics.mdanderson.org/Software/FamSeq/FamSeq1.0.3.tar.gz -O FamSeq.tar.gz
tar xvf FamSeq.tar.gz
cd FamSeq/src/ 
make 
sudo ln -s `pwd`/FamSeq /usr/bin/FamSeq
cd ../..
FamSeq -h
#
sudo apt install python2.7 python-pip -y
# python version
python --version

##aws s3 cp s3://vccri-giannoulatou-lab-clihad-deepvariant/gsutil.tar.gz .
wget https://storage.googleapis.com/pub/gsutil.tar.gz
tar xfz gsutil.tar.gz -C $HOME
#sudo ln -s $HOME/gsutil /usr/bin/gsutil
#export PATH=${PATH}:$HOME/gsutil
#echo $PATH
#
#java
sudo apt-get -y install openjdk-8-jre-headless
#
#GATK
#wget https://github.com/broadinstitute/gatk/releases/download/4.1.2.0/gatk-4.1.2.0.zip
wget https://github.com/broadinstitute/gatk/releases/download/4.1.3.0/gatk-4.1.3.0.zip
sudo apt-get -y install unzip
#unzip gatk-4.1.2.0.zip
unzip gatk-4.1.3.0.zip
mv gatk-4.1.3.0 gatk
