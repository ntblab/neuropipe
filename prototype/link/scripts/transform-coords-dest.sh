#!/bin/bash
# author: mgsimon@princeton.edu

set -e


if [ $# -ne 4 ]; then
  echo "
usage: `basename $0` src_coords_file src_feat_dir dest_feat_dir dest_coords_file


Transforms the coordinates in src space contained in src_coords_file into a
corresponding set of coordinates in dest space, and saves them into 
dest_coords_file. This is useful if you want to transform coordinates from the space of
one run to another run (within subjects).

REQUIREMENTS:
 - FSL's img2imgcoord command must be on the path
  "
  exit 1
fi


src_coords_file=$1
src_feat_dir=$2
dest_feat_dir=$3
dest_coords_file=$4


src_reg_dir=$src_feat_dir/reg
dest_reg_dir=$dest_feat_dir/reg
standard_coords_file=$(mktemp -p test)


# here we tranform coords src -> standard -> dest

# NOTE: the "| sed '1d; $d'" in the following commands chops off the header and
# trailing line that img2imgcoord adds.
img2imgcoord -src $src_reg_dir/example_func.nii.gz -dest $dest_reg_dir/standard.nii.gz -xfm $dest_reg_dir/example_func2standard.mat $src_coords_file | sed '1d;$d' > $standard_coords_file
img2imgcoord -src $dest_reg_dir/standard.nii.gz -dest $dest_reg_dir/example_func.nii.gz -xfm $dest_reg_dir/standard2example_func.mat $standard_coords_file | sed '1d; $d' > $dest_coords_file


rm -f $standard_coords_file
