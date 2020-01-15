#!/bin/bash
############################################################
#                                                          #
#   Output some useful job information.                    #
#    **Modified from example script by K Cahill**          #
#    https://www.osc.edu/sites/osc.edu/files/staff_files/  #
#                                 kcahill/sample_job.pbs   #
#                                                          #
############################################################

echo ------------------------------------------------------
echo -n 'Job is running on node '; cat $PBS_NODEFILE
echo ------------------------------------------------------
echo PBS: qsub is running on $PBS_O_HOST
echo PBS: executing queue is $PBS_QUEUE
echo PBS: working directory is $PBS_O_WORKDIR
echo PBS: job identifier is $PBS_JOBID
echo PBS: job name is $PBS_JOBNAME
echo PBS: node file is $PBS_NODEFILE
echo PBS: current home directory is $PBS_O_HOME
echo PBS: PATH = $PBS_O_PATH
echo PBS: tempdir = $tmpdir
echo ------------------------------------------------------
