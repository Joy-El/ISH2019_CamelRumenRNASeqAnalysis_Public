#!/bin/bash -l
######################################################################
#                                                                    #
#  Build Bowtie2 Libraries                                           #
#    1) rDNA of Eukaryotes                                           #
#    2) rDNA of Prokaryotes                                          #
#    3) rDNA of Archaea                                              #
#    4) Camel Genome                                                 #
#    5) Carp Genome                                                  #
#    6) Alfalfa & Cucumber mosaic virus                              #
#    7) Camel metagenome                                             #
#                                                                    #
######################################################################
echo "************************************************************************"
echo "Building Libraries"
echo "************************************************************************"
echo

echo "Creating base directory for completed libraries"
libraries="$PBS_O_WORKDIR/../data/reference_sequences/bowtie_libraries/"
echo $libraries
mkdir $libraries

path_reference_seq="$PBS_O_WORKDIR/../data/reference_sequences"

for arg in "$@"; do
  echo $arg
  case $arg in
    1)
    echo "$(date) - Building Eukaryotic rDNA Bowtie Library"
    mkdir ${tmpdir}/eukrDNA/
    cd ${path_reference_seq}/rDNA
    cp arb-silva.de_2019-12-25_id760523.tgz ${tmpdir}/eukrDNA/
    cd ${tmpdir}/eukrDNA/

    tar -xzf *.tgz

    bowtie2-build --seed 1143 --threads 16 -f *.fa* silva_euk_rDNA

    rm *.tgz
    rm *.fa*
    mv silva_euk_rDNA.* $libraries

    echo "$(date) - silva_euk_rDNA library complete"
    ;;

    2)
    echo "$(date) - Building Prokaryotic rDNA Bowtie Library"
    mkdir ${tmpdir}/prokrDNA/
    cd ${path_reference_seq}/rDNA
    cp prokaryote.tgz ${tmpdir}/prokrDNA/
    cd ${tmpdir}/prokrDNA/
    tar -xzf prokaryote.tgz

    bowtie2-build --seed 1143 --threads 16 -f prokaryote.fa silva_prok_rDNA

    rm *.tgz
    rm *.fa*
    mv silva_prok_rDNA.* $libraries

    echo "$(date) - silva_prok_rDNA library complete"
    ;;

    3)
    echo "$(date) - Building Archaea rDNA Bowtie Library"
    mkdir ${tmpdir}/archrDNA/
    cd ${path_reference_seq}/rDNA
    cp arb-silva.de_2019-12-23_id760325.tgz ${tmpdir}/archrDNA/
    cd ${tmpdir}/archrDNA/

    tar -xzf *.tgz

    bowtie2-build --seed 1143 --threads 16 -f *.fa* silva_arch_rDNA

    rm *.tgz
    rm *.fa*
    mv silva_arch_rDNA.* $libraries

    echo "$(date) - silva_arch_rDNA library complete"
    ;;

    4)
    echo "$(date) - Building Camel gDNA Bowtie Library"
    mkdir ${tmpdir}/camelgDNA/
    cd ${path_reference_seq}/camelus_dromedarius
    cp GCA_000803125.3_CamDro3_genomic.fna.gz ${tmpdir}/camelgDNA/
    cd ${tmpdir}/camelgDNA/

    gunzip GCA_000803125.3_CamDro3_genomic.fna.gz

    bowtie2-build --seed 1143 --threads 16 \
    -f GCA_000803125.3_CamDro3_genomic.fna \
    camel_gDNA

    rm *.tgz
    rm *.fa*
    mv camel_gDNA.* $libraries

    echo "$(date) - camel_gDNA library complete"
    ;;

    5)
    echo "$(date) - Building Carp gDNA Bowtie Library"
    mkdir ${tmpdir}/carp_gDNA/
    cd ${path_reference_seq}/cyprinus_carpio
    cp GCF_000951615.1_common_carp_genome_genomic.fna.gz ${tmpdir}/carp_gDNA/
    cd ${tmpdir}/carp_gDNA/

    gunzip GCF_000951615.1_common_carp_genome_genomic.fna.gz

    bowtie2-build --seed 1143 --threads 16 \
    -f GCF_000951615.1_common_carp_genome_genomic.fna \
    carp_gDNA

    rm *.tgz
    rm *.fa*
    mv carp_gDNA.* $libraries

    echo "$(date) - carp_gDNA library complete"
    ;;

    6)
    echo "$(date) - Building Alfalfa Mosaic Virus Bowtie Library"
    mkdir ${tmpdir}/AMV/
    cd ${path_reference_seq}/alfalfa_mosaic_virus
    cp GCF_000847525.1_ViralMultiSegProj14667_genomic.fna.gz ${tmpdir}/AMV/
    cd ${tmpdir}/AMV/

    gunzip GCF_000847525.1_ViralMultiSegProj14667_genomic.fna.gz

    bowtie2-build --seed 1143 --threads 16 \
    -f GCF_000847525.1_ViralMultiSegProj14667_genomic.fna \
    mosaic_virus_gDNA

    rm *.tgz
    rm *.fa*
    mv mosaic_virus_gDNA.* $libraries

    echo "$(date) - mosaic_virus_gDNA library complete"
    ;;

    7) echo "Building Camel metagenome Bowtie Library"
    ;;

  esac
done

echo
echo "************************************************************************"
echo "Finished building libraries"
echo "************************************************************************"
