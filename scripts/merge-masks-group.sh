#!/bin/bash
#Author: ntb
#Edited by: Alexa Tompary

set -e # stop immediately when an error occurs

if [ $# -ne 2 ]; then
  echo "
usage: `basename $0` roi_dir mask_file

This script opens all subjects' masks of a specified roi into fslview,
so you can see exactly where everyone's ROI is in standard space. 

  "
  exit 1
fi

roi_dir=$1
mask_file=$2

source globals.sh

subjnum=`ls -A subjects | wc -l`

#if running locally, switch to the other fvstring or modify it to your computer's path to standard brains
#fvstring='/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz '
fvstring='/usr/pni/pkg/FSL/fsl-4.1.6/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz '
formatstring=' -l Cool -b 0,'$subjnum' '

counter=0
for subj in $NON_EXCLUDED_SUBJECTS; do
	roidir=subjects/$subj/$roi_dir
	let counter+=1
	fslmaths $roidir/${mask_file} -mul $counter $roidir/${mask_file}_for_group
	fvstring=${fvstring}${roidir}/${mask_file}_for_groupfslvie$formatstring
done

fslview $fvstring &
