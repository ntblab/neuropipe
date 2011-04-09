#!/bin/bash
#Author: ntb
#Edited by: Alexa Tompary

set -e # stop immediately when an error occurs

if [ $# -ne 2 ]; then
  echo "
usage: `basename $0` roi_dir roi 

This script opens all subjects' masks of a specified roi into fslview,
so you can see exactly where everyone's ROI is in standard space. 

  "
  exit 1
fi

roi_dir=$1
roi=$2

source globals.sh

#wildly unneccesary way to find out how many subjects are listed in the subject dir
subjnum=`ls -A subjects | wc -l | cut -c 8-` 

#if running locally, switch to the other fvstring or modify it to your computer's path to standard brains
#fvstring='/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz '
fvstring='/usr/pni/pkg/FSL/fsl-4.1.6/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz '
formatstring=' -l Cool -b 0,'$subjnum

counter=0
for subj in $NON_EXCLUDED_SUBJECTS; do
	roidir=subjects/$subj/$roi_dir
	let counter+=1
	fslmaths $roidir/mask_${roi}.nii.gz -mul $counter $roidir/mask_${roi}.nii.gz
	fvstring=${fvstring}${roidir}/mask_${roi}.nii.gz$formatstring
done

fslview $fvstring &