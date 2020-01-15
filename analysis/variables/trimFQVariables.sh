#!/bin/bash -l
echo "*************************************************************************"
echo "Variable Definition for:"
echo "    - src/trimFQ.sh"
echo "*************************************************************************"
echo

echo "Input Files"
input_path="$PBS_O_WORKDIR/../data/raw_sequences/" # path from home/analysis/ to file location
input_r1="HI.3512.003.Index_*_R1.fastq.gz"
input_r2="HI.3512.003.Index_*_R2.fastq.gz"

# for testing only (comment out on true run)
#input_r1="sample_R1.fq.gz"
#input_r2="sample_R2.fq.gz"

export input_path input_r1 input_r2
echo "R1 FASTQ files:"
ls $input_path$input_r1
echo
echo "R2 FASTQ files:"
ls $input_path$input_r2
echo

echo "Output Folders"
# define output file locations
fastqc_out1="$PBS_O_WORKDIR/../results/fastqc_pre-trim/"
trimmed_out="$PBS_O_WORKDIR/../data/trimmed/" # storing in data as it will be input for next script
fastqc_out2="$PBS_O_WORKDIR/../results/fastqc_post-trim/"

export fastqc_out1 trimmed_out fastqc_out2
echo "First FASTQC Run: $fastqc_out1"
echo "Trimmed FASTQ: $trimmed_out"
echo "Second FASTQC Run: $fastqc_out2"
echo

echo "Trimmomatic Details"
# define details for trimmomatic trim
# update to change stringency
# ILLUMINACLIP:TruSeq3-PE-2.fa:2:12:6 - remove adapters: <FASTA of adapters>:<seed mismatches>:<palindrome clip threshold>:<simple clip threshold>
# LEADING:10 - remove leading low qual (below 10) or N bases
# TRAILING:10 - remove trailing low qual (below 10) or N bases
# SLIDINGWINDOW:5:16 - scan read in 5bp sliding window cutting when average quality per base below 16
# MINLEN:30 - drop reads shorter than 30bp
trimmer="ILLUMINACLIP:TruSeq3-PE-2.fa:2:12:6 \
LEADING:10 \
TRAILING:10 \
SLIDINGWINDOW:5:16 \
MINLEN:30"
adapter_seq="$PBS_O_WORKDIR/../data/TruSeq3-PE-2.fa"

export trimmer adapter_seq
echo "Location of adapter FASTA: $adapter_seq"
echo "Trimmomatic Variables:"
echo $trimmer
echo
echo
