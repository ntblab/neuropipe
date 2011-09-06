#!/bin/sh
# author: mgsimon@princeton.edu

if [ $# -lt 3 ]; then
  echo "
usage: $0 4d_zstat_image threshold output_image

this script takes a 4d image of zstats over time, and a threshold, then
outputs a 3d map of the timepoint (with 1 being the first) at which the
given 4d image achieved its maximum intensity, but masked to only show
voxels that at some point had a zstat greater than the given threshold.
"
  exit -1
fi


image_4d=$1
z_thresh=$2
output_image=$3

mask=$(mktemp)


# see http://mathworld.wolfram.com/GaussianFunction.html for the FWHM formula.
fwhm_in_mms=5
fwhm_in_sds=$(echo "${fwhm_in_mms}/(2*sqrt(2*l(2)))" | bc -l)

# form a mask by taking the max over time, filtering with a 5mm FWHM Gaussian
# kernel, then thresholding by z_thresh, then use that mask on the map that
# holds the time index of greatest intenstity at each voxel.

fslmaths $image_4d -Tmax -kernel gauss $fwhm_in_sds -fmean -abs -sub $z_thresh -bin $mask
fslmaths $image_4d -Tmaxn -add 1 -mul $mask $output_image   # adding 1 prevents the first timepoint from being black
rm -f $mask

