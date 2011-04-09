#!/bin/bash
#Author: Alexa Tompary

set -e

if [ $# -ne 6 ]; then
  echo "
usage: `basename $0` x-coordinate y-coordinate z-coordinate mask_file sphere_file dest_dir

This script overlays spherical ROIs (transformed into standard space) onto template brain, 
saved as masks.

  "
  exit 1
fi

xcoord=$1
ycoord=$2
zcoord=$3
mask_file=$4
sphere_file=$5
dest_dir=$6

fslmaths /usr/pni/pkg/FSL/fsl-4.1.6/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -roi $xcoord 1 $ycoord 1 $zcoord 1 0 1 ${dest_dir}/${mask_file}
fslmaths ${dest_dir}/${mask_file}.nii.gz -kernel sphere 4 -fmean -bin -thr .00001 ${dest_dir}/${sphere_file}
