#!/bin/bash
#Author: Alexa Tompary

set -e


if [ $# -ne 4 ]; then
  echo "
usage: `basename $0` roi_coords roi_names loc_feat_dir dest_dir

This script uses the three-column ROI coordinates file (created by pick-rois-interactive.sh)
and creates a mask for each specified ROI. Each mask includes bilateral ROIs.

  "
  exit 1
fi

roi_coords=$1
roi_names=$2
loc_feat_dir=$3
dest_dir=$4

source globals.sh

mkdir -p $dest_dir

scripts/transform_coords_std.sh $roi_coords $loc_feat_dir $dest_dir/roi_coords_std.txt

  l=0
  cat ${dest_dir}/roi_coords_std.txt | while read line; do
	xcoord=`echo $line | cut -d\  -f 1`
	ycoord=`echo $line | cut -d\  -f 2`
	zcoord=`echo $line | cut -d\  -f 3`
  l=`expr $l + 1`	
    bash scripts/make_masks.sh $xcoord $ycoord $zcoord point_mask_${l}.nii.gz sphere_mask_${l}.nii.gz $dest_dir
  done

m=`ls -l $dest_dir/sphere_mask* | wc -l`

for ((r=1;r<=$m;r++)); do
	rem=$(($r%2))
	if [ $rem -eq 1 ]; then
		ln=0
		while read roi; do
			ln=`expr $ln + 1`
			if [ $ln -eq $r ]; then
				roi=`echo $roi | cut -c 2-`
				fslmaths ${dest_dir}/sphere_mask_${r} -add ${dest_dir}/sphere_mask_$((${r}+1)) ${dest_dir}/mask_${roi}.nii.gz
			fi
		done < $roi_names
	fi
done

rm -rf ${dest_dir}/sphere_mask_?.nii.gz
rm -rf ${dest_dir}/point_mask_?.nii.gz
