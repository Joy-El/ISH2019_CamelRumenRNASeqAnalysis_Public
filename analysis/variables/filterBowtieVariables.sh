#!/bin/bash -l
echo "*************************************************************************"
echo "Variable Definition for:"
echo "    - src/runBowtieFilter.sh"
echo "*************************************************************************"
echo

echo "Input Files (FASTA sequences)"
input_path="$PBS_O_WORKDIR/../data/trimmed/" # path from home/analysis/ to file location
input_r1="trimmed.paired*_R1.fq.gz"
input_r2="trimmed.paired*_R2.fq.gz"
input_unpaired="trimmed.unpaired*_R0.fq.gz"

# single library test (for time estimate)
#input_r1="trimmed.paired.HI.3512.003.Index_11.1_R1.fq.gz"
#input_r2="trimmed.paired.HI.3512.003.Index_11.1_R2.fq.gz"
#input_unpaired="trimmed.unpaired.HI.3512.003.Index_11.1_R0.fq.gz"

# for testing only (comment out on true run)
#input_r1="trimmed.paired.sample_R1.fq.gz"
#input_r2="trimmed.paired.sample_R2.fq.gz"
#input_unpaired="trimmed.unpaired.sample_R0.fq.gz"

export input_path input_r1 input_r2 input_unpaired
echo "R1 FASTQ files:"
ls $input_path$input_r1
echo
echo "R2 FASTQ files:"
ls $input_path$input_r2
echo
echo "R0 FASTQ files (unpaired):"
ls $input_path$input_unpaired
echo

echo "Reference Library"
library_path="$PBS_O_WORKDIR/../data/reference_sequences/bowtie_libraries/"
library_base="silva_euk_rDNA silva_arch_rDNA silva_prok_rDNA camel_gDNA carp_gDNA mosaic_virus_gDNA"

export library_path library_base
echo
echo "Library files:"
for library in $library_base; do
  ls $library_path${library}.*
done
echo

echo "Bowtie alignment parameters:"
bowtie_param="--phred33 \
--fast-local \
--sam-no-qname-trunc \
--threads 16 \
--seed 1143 \
--no-unal"
export bowtie_param
echo $bowtie_param
echo

echo "Output Folders"
# define output file locations
bowtie_results="$PBS_O_WORKDIR/../results/bowtie/"
filtered_reads="$PBS_O_WORKDIR/../data/filtered_reads/"

export bowtie_results filtered_reads
echo "Bowtie Results: $bowtie_results"
echo "Filtered Reads: $filtered_reads"
echo
