#!/bin/bash
# author: mgsimon@princeton.edu

set -e


if [ $# -ne 5 ]; then
  echo "
  usage: `basename $0` input scaling_factor mean_image mask_image output

  transforms the given image of beta values into an image of % signal change,
  given an appropriate scaling factor (which you must determine), mean signal
  image, and mask image, following the method described in:
  http://mumford.bol.ucla.edu/perchange_guide.pdf.

  the transformed file is named according to the output parameter
  "
  exit
fi


input_image=$1
scaling_factor=$2
mean_image=$3
mask_image=$4
output_image=$5


fslmaths "$input_image" \
         -mul "$scaling_factor" \
         -div "$mean_image" \
         -mul "$mask_image" \
         -mul "100.0" \
         "$output_image"

