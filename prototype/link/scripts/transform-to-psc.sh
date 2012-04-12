#!/bin/bash
# author: mgsimon@princeton.edu

set -e

source globals.sh

if [ $# -ne 5 ]; then
  echo "
  usage: `basename $0` input mean_image mask_image output scaling_factor

  transforms the given image of beta values into an image of % signal change,
  given an appropriate scaling factor (which you must determine), mean signal
  image, and mask image, following the method described in:
  http://mumford.bol.ucla.edu/perchange_guide.pdf.

  the transformed file is named according to the output parameter
  "
  exit
fi


input_image=$1
mean_image=$2
mask_image=$3
output_image=$4
scaling_factor=$5


fslmaths "$input_image" \
         -mul "$scaling_factor" \
         -div "$mean_image" \
         -mul "$mask_image" \
         -mul "100.0" \
         "$output_image"

