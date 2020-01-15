#!/bin/bash -l
######################################################################
#                                                                    #
#  Trimmomatic Run                                                   #
#     1) Run FASTQC on sample to get baseline                        #
#     2) Run Trimmomatic to remove adapters and low qual bases/reads #
#     3) Re-run FASTQC for post-trim details                         #
#     4) Store stats about reads trimmed or dropped                  #
#                                                                    #
######################################################################
echo "************************************************************************"
echo "Starting FASTQ file processing"
echo "************************************************************************"
echo

# setup directories as needed
mkdir -p $fastqc_out1
mkdir -p $trimmed_out
mkdir -p $fastqc_out2


####################################################################
#                                                                  #
#  Move files to node                                              #
#                                                                  #
####################################################################
echo "Transferring files from Working Directory to node's local directory"
pwd
echo "move to $tmpdir"
cd $tmpdir
pwd
echo "Files in node work directory:"
ls -lrt

echo
echo "Adding input files:"
cp $input_path$input_r1 .
cp $input_path$input_r2 .
cp $adapter_seq .

echo "Files in node work directory: "
ls -lrt
echo

########################################################################
#                                                                      #
#  Process the FASTQ.GZ files to generate following                    #
#     1) Count of reads pre-cleanup                                    #
#     2) FASTQC results                                                #
#     3) Trim adapters & low qual reads                                #
#     4) FASTQC follow-up                                              #
#     5) Counts of reads post-cleanup                                  #
#     6) Zip & move to new data dir (data/trimmed)                     #
#                                                                      #
########################################################################
echo "Looping through FASTQ files"
echo
echo "List of files: $(ls $input_r1)"
echo
for r1file in $(ls $input_r1); do
  # create base name
  base=${r1file%_R1*}                 # remove _R1.fq.gz

  echo "Processing sample: $base"

  gunzip ${base}_R1*.gz
  gunzip ${base}_R2*.gz

  echo "  Item 1: count of reads pre-trim"
  echo "Pre-trim,${base}_R1,$(wc -l ${base}_R1.*)" >> readcounts.csv
  echo "Pre-trim,${base}_R2,$(wc -l ${base}_R2.*)" >> readcounts.csv

  echo "  Item 2: FASTQC pre-trim"
  fastqc ${base}_R1.*
  fastqc ${base}_R2.*
  cp *.zip $fastqc_out1
  cp *.html $fastqc_out1
  rm *.zip
  rm *.html

  echo "  Item 3: Trim Adapters & Low Qual Reads"
  java -jar $TRIMMOMATIC PE \
  ${base}_R1.*                       `# input forward` \
  ${base}_R2.*                       `# input reverse` \
  trimmed.paired.${base}_R1.fq       `# output forward paired` \
  trimmed.unpaired.${base}_R1.fq     `# output forward unpaired` \
  trimmed.paired.${base}_R2.fq       `# output reverse paired` \
  trimmed.unpaired.${base}_R2.fq     `# output reverse unpaired` \
  $trimmer                            # settings

  echo "  Item 4: FASTQC post-trim"
  fastqc trimmed.paired.${base}_R1.fq trimmed.unpaired.${base}_R1.fq
  fastqc trimmed.paired.${base}_R2.fq trimmed.unpaired.${base}_R2.fq
  cp *.zip $fastqc_out2
  cp *.html $fastqc_out2
  rm *.zip
  rm *.html

  echo "  Item 5: count of reads post-trim"
  echo "Post-trim;paired,${base}_R1,$(wc -l trimmed.paired.${base}_R1.fq)" >> readcounts.csv
  echo "Post-trim;unpaired,${base}_R1,$(wc -l trimmed.unpaired.${base}_R1.fq)" >> readcounts.csv
  echo "Post-trim;paired,${base}_R2,$(wc -l trimmed.paired.${base}_R2.fq)" >> readcounts.csv
  echo "Post-trim;unpaired,${base}_R2,$(wc -l trimmed.unpaired.${base}_R2.fq)" >> readcounts.csv

  echo "  Item 6: zip files & cleanup"
  gzip trimmed.paired.*fq
  # concat all unpaired trimmed and use dummy "R0" to reference (so it matches name format of paired)
  cat trimmed.unpaired.*R1.fq trimmed.unpaired.*R2.fq | gzip > trimmed.unpaired.${base}_R0.fq.gz
  cp trimmed*.gz $trimmed_out

  # cleanup
  rm *${base}*

done

echo
echo "************************************************************************"
echo "Finished processing FASTQ files"
echo "************************************************************************"
echo
echo "Copying remaining files back to working directory"
mv readcounts.csv $PBS_O_WORKDIR/../results/
