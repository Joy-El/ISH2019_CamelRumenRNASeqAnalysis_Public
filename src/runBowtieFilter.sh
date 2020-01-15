#!/bin/bash -l
######################################################################
#                                                                    #
#  Run Bowtie2 Filter                                                #
#    1) loops through fastq file sets of R1 & R2 pairs               #
#          plus R0 unpaired                                          #
#    2) loops through reference bowtie_libraries                     #
#    3) unaligned output of each bowtie run used to                  #
#          generate R1, R2, and R0 for next running                  #
#    4) final run will move filtered files to data directory         #
#                                                                    #
######################################################################
echo "************************************************************************"
echo "Filtering reads with Bowtie2"
echo "************************************************************************"
echo

# setup directories as needed
mkdir -p $bowtie_results
mkdir -p $filtered_reads

echo "Looping through FASTQ files to run bowtie2"
echo

echo "Copying bowtie2 libraries to $tmpdir"
cd $tmpdir
for library in $library_base; do
  cp ${library_path}${library}.* .
done
ls
echo

echo "Starting to loop through FASTQ file sets"
for r1file in $(ls $input_path$input_r1); do
  # create base name
  base=${r1file##*trimmed.paired.}      # remove prefix including path pieces
  base=${base%_R1*}                     # remove _R1.fq.gz

  echo "*************************************"
  echo "  Processing $base sequence files"
  # setup tmpdir space
  output="$tmpdir/$base/"
  mkdir $output
  export output

  echo "    1. copying initial sequence files from $input_path"
  cp ${input_path}*${base}* .
  gunzip *${base}*.gz

  echo "    2. adjusting filenames to match pattern used in looping"
  mv trimmed.paired.${base}_R1.fq R1.fq
  mv trimmed.paired.${base}_R2.fq R2.fq
  mv trimmed.unpaired.${base}_R0.fq R0.fq
  ls -l -h --ignore=*.bt2* # hide the library files

  counter=3
  export counter

  # inner loop through various reference libraries
  for library in $library_base; do
    echo "    ${counter}a. Filtering against $library"
    out_base="$output${library}-${base}_R.fq" #bowtie will add .1 & .2 in the --un-conc piece
    out_R1="$output${library}-${base}_R.1.fq"
    out_R2="$output${library}-${base}_R.2.fq"
    out_R0="$output${library}-${base}_R0.fq"
    out_mapped="$output${library}-${base}_mapped.sam"

    echo "**** paired-end & singleton bowtie ****"
    # paired end bowtie
    bowtie2 $bowtie_param \
    --un $out_R0 \
    --un-conc $out_base \
    -x $library \
    -1 R1.fq \
    -2 R2.fq \
    -U R0.fq \
    -S $out_mapped

    echo "    ${counter}b. Preparing for next library"
    echo "Files in $output after bowtie runs:"
    ls -lh $output # to make sure we have what we expect
    echo "Files in base dir after bowtie runs (exclude libraries):"
    ls -lh --ignore=*.bt2*

    cp $out_R1 R1.fq
    cp $out_R2 R2.fq
    cp $out_R0 R0.fq
    counter=$((counter + 1))
    export counter

    wc -l $out_R1 >> bowtie_filter_filelines.txt
    wc -l $out_R2 >> bowtie_filter_filelines.txt
    wc -l $out_R0 >> bowtie_filter_filelines.txt
    rm $out_R1
    rm $out_R2
    rm $out_R0

    cp $out_mapped $bowtie_results
    rm $out_mapped
  done

  echo "    ${counter}. Moving final filtered sequences to $filtered_reads"

  # return to descriptive names
  mv R1.fq filtered_${base}_R1.fq
  mv R2.fq filtered_${base}_R2.fq
  mv R0.fq filtered_${base}_R0.fq
  gzip filtered*.fq
  cp filtered*.fq.gz $filtered_reads
  rm filtered*.fq*
done

cp bowtie_filter_filelines.txt $bowtie_results

echo
echo "************************************************************************"
echo "Finished filtering sequences"
echo "************************************************************************"
