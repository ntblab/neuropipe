#!/bin/bash
#Author: Alexa Tompary

set -e


if [ $# -ne 4 ]; then
  echo "
usage: `basename $0` roi_coords_txt roi_names_txt src_dir dest_dir

This script uses the ROI region names tetx file as well as the three-column ROI coordinates file 
(created by pick-rois-interactive.sh) to create a mask for each specified ROI. 'src_dir' is the
Feat directory of the localizer run used to pick your ROI coordinates; the script looks in there
to use registration transformations to put your coordinates in standard space before creating 
the masks

Each mask includes bilateral ROIs. This script cannot be used for unilateral ROIs.

  "
  exit 1
fi

roi_coords=$1
roi_names=$2
src_dir=$3
dest_dir=$4

source globals.sh

mkdir -p $dest_dir

scripts/transform-coords-std.sh $roi_coords $src_dir $dest_dir/roi_coords_std.txt

  l=0
  cat ${dest_dir}/roi_coords_std.txt | while read line; do
	xcoord=`echo $line | cut -d\  -f 1`
	ycoord=`echo $line | cut -d\  -f 2`
	zcoord=`echo $line | cut -d\  -f 3`
  l=`expr $l + 1`	
    bash scripts/make-masks.sh $src_dir $xcoord $ycoord $zcoord sphere_mask_${l}.nii.gz $dest_dir
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
rm -rf ${dest_dir}/point_mask.nii.gz
