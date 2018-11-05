#install

# gsutil

# curl https://sdk.cloud.google.com | bash
# exec -l $SHELL

mkdir -p lib

# htslib
wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2 -O htslib.tar.bz2
tar -xjvf htslib.tar.bz2
cd htslib-1.9
make
sudo make install
cd ..

# samtools
wget https://github.com/samtools/samtools/releases/download/1.8/samtools-1.8.tar.bz2 -O samtools.tar.bz2
tar -xjvf samtools.tar.bz2
cd samtools-1.8
./configure --without-curses
make
sudo make prefix=/usr/local/bin install
sudo ln -s /usr/local/bin/bin/samtoos /usr/bin/samtools
cd ..

# bcftools
wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2 -O bcftools.tar.bz2
tar -xjvf bcftools.tar.bz2
cd bcftools-1.9
make
sudo make prefix=/usr/local/bin install
sudo ln -s /usr/local/bin/bin/bcftools /usr/bin/bcftools
cd ..

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

# vt
git clone https://github.com/atks/vt.git  
cd vt
make
make test
sudo ln -s `pwd`/vt /usr/bin/vt
cd ..

# parallel
sudo apt-get -y update
sudo apt-get -y install parallel
# sudo apt-get -y install samtools
# sudo apt-get -y install docker.io

# FamSeq
wget http://bioinformatics.mdanderson.org/Software/FamSeq/FamSeq1.0.3.tar.gz -O FamSeq.tar.gz
tar xvf FamSeq.tar.gz
cd FamSeq/src/ 
make 
sudo ln -s `pwd`/FamSeq /usr/bin/FamSeq
cd ../..



