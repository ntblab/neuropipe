#!/bin/bash
#Author: Alexa Tompary

set -e

if [ $# -ne 6 ]; then
  echo "
usage: `basename $0` src_dir x-coordinate y-coordinate z-coordinate sphere_file dest_dir

This script overlays spherical ROIs (transformed into standard space) onto template brain, 
saved as masks.

  "
  exit 1
fi

src_dir=$1
xcoord=$2
ycoord=$3
zcoord=$4
sphere_file=$5
dest_dir=$6

fslmaths ${src_dir}/reg/standard.nii.gz -roi $xcoord 1 $ycoord 1 $zcoord 1 0 1 ${dest_dir}/point_mask
fslmaths ${dest_dir}/point_mask.nii.gz -kernel sphere 4 -fmean -bin -thr .00001 ${dest_dir}/${sphere_file}
