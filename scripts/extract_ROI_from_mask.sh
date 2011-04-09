#!/bin/bash -e

if [ $# -ne 2 ]; then
  echo "
usage: `basename $0` src_roi_file src_feat_dir


This script reads ROI coordinates from a text file and extracts them (in standard space) 
from a manually segmented mask (specified here as data/nifti/${subj}_t2_tse01-mask.nii.gz)
in NIFTI format. Change the file name in line 56 if your mask is named differently. 

Note: this script assumes you are using standardized brain data from a firstlevel feat
directory. If this is not the case, change the path in line 46 to the correct feat directory.

REQUIREMENTS:
 - FSL's flirt and fslmaths commands must be on the path.
  "
  exit 1
fi

coords=$1
feat_dir=$2

source globals.sh

if [ -d "results/extracted_rois" ]; then
  read -t 5 -p "ROIs have already been extracted. overwrite? (y/N) " overwrite || true
  if [ "$overwrite" != "y" ]; then exit; fi
  rm -rf results/extracted_rois
fi

mkdir -p results/extracted_rois

# read in regions
i=0
while read roi; do
  rois["$i"]=$roi
  i=($i+1)
done <$coords

for subj in $NON_EXCLUDED_SUBJECTS; do

	data_dir=${PROJECT_DIR}/subjects/${subj}/data/nifti
	reg_dir=${PROJECT_DIR}/subjects/${subj}/data/nifti
	feat_dir=${PROJECT_DIR}/subjects/${subj}/analysis/firstlevel/${feat_dir}
	
	mkdir -p ${data_dir}/ROI_files
	
	#echo getting registration matrix for t2tse to high res for $subj
	#flirt -ref ${data_dir}/${subj}_t1_mprage_brain.nii.gz -in ${data_dir}/${subj}_t2_tse01.nii.gz -out ${data_dir}/ROI_files/T2tse2highres -omat ${data_dir}/ROI_files/T2tse2highres.mat -cost corratio -dof 6 -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -interp trilinear
	
	j=0
	for roi in "${rois[@]}"; do
		let j=($j+1)
		
		echo creating ROI masks for $subj -- ROI: $roi
		fslmaths ${data_dir}/${subj}_t2_tse01-mask.nii.gz -thr $j -uthr $j ${data_dir}/ROI_files/${roi}_mask.nii.gz

		echo registering ROI to high res for $subj -- ROI: $roi
		flirt -ref ${data_dir}/${subj}_t1_mprage_brain.nii.gz -in ${data_dir}/ROI_files/${roi}_mask.nii.gz -out ${data_dir}/ROI_files/${roi}_T2tse2highres.nii.gz -applyxfm -init ${data_dir}/ROI_files/T2tse2highres.mat -interp sinc -datatype float

		echo registering ROI to standard for $subj -- ROI: $roi
		flirt -ref ${feat_dir}/reg/standard -in ${data_dir}/ROI_files/${roi}_T2tse2highres -out ${data_dir}/ROI_files/${roi}_std.nii.gz -applyxfm -init ${feat_dir}/reg/highres2standard.mat -interp sinc -datatype float

		echo binarizing ROI masks for $subj -- ROI: $roi
		fslmaths ${data_dir}/ROI_files/${roi}_std.nii.gz -bin ${data_dir}/ROI_files/${roi}_std_bin.nii.gz

	done
done
