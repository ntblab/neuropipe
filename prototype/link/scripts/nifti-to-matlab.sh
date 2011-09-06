#!/bin/bash -e
# author: Alexa Tompary

if [ $# -ne 2 ]; then
  echo "
usage: `basename $0` nifti_file output_file 

reads the data from a gzipped NIfTi file into a matlab file. BXH XCEDE and 
BIAC_matlab tools must be in the path for this script to run

see http://nbirn.net/tools/bxh_tools/index.shtm for details on BXH headers.
  "
  exit
fi

source globals.sh

nifti_file=$1
output_file=$2

nifti_dir=$(dirname $nifti_file)
output_dir=$(dirname $output_file)

#unzip nifti file if not done already
if [ "${nifti_file/*./}" = "gz" ]; then
	gunzip $nifti_file
fi

#get bxh header for nifti files
input_file=$(basename $nifti_file)
stripped_file=${input_file%%.*} 
bxh_file=${stripped_file}.bxh
bxhabsorb ${nifti_dir}/${stripped_file}.nii ${output_dir}/$bxh_file

#read bxh header into matlab and save structure to output file name
(printf "addpath(genpath('$BIAC_HOME')); "
printf "nifti_struct = readmr('$output_dir/$bxh_file','NOPROGRESSBAR'); "
printf "save $output_file nifti_struct") | matlab -nodisplay > /dev/null




