#!/bin/bash
# author: mgsimon@princeton.edu

set -e


if [ $# -ne 3 ]; then
  echo "
usage: `basename $0` src_coords_file src_feat_dir std_coords_file


transforms the coordinates in src space contained in src_coords_file into a
corresponding set of coordinates in standard space, and saves them into 
std_coords_file

REQUIREMENTS:
 - FSL's img2imgcoord command must be on the path
  "
  exit 1
fi


src_coords_file=$1
src_feat_dir=$2
std_coords_file=$3


src_reg_dir=$src_feat_dir/reg

# NOTE: the "| sed '1d; $d'" in the following commands chops off the header and
# trailing line that img2imgcoord adds.
img2imgcoord -src $src_reg_dir/example_func.nii.gz -dest $src_reg_dir/standard.nii.gz -xfm $src_reg_dir/example_func2standard.mat $src_coords_file | sed '1d;$d' > $std_coords_file
