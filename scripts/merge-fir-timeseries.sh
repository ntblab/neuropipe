#!/bin/bash
#
# author: mgsimon@princeton.edu
# this script groups all the lags for each FIR into 4D images

set -e


if [ $# -ne 6 ]; then
  echo "
usage: `basename $0` first_level_fsf_template stat_file num_regressors num_lags thirdlevel_dir output_dir

groups all of the lags for each regressor into 4D images

REQUIREMENTS:
 - FSL must be on the path
  "
  exit
fi

first_level_template=$1
stat_file=$2
NUM_REGRESSORS=$3
NUM_LAGS=$4
THIRDLEVEL_DIR=$5
output_dir=$6

TOTAL_PES=$(echo "$NUM_LAGS * $NUM_REGRESSORS" | bc)


# the next lines extract the regressor names from the first level design.fsf
# template. try out the grep command on its own to see how this works
regressor_names=($(grep "set fmri(conname.orig" $first_level_template \
                     | cut --delimiter='"' --fields=2-2))
# firsts are the indices of the first FIR lags for each regressor
firsts=($(seq 1 $NUM_LAGS $TOTAL_PES))

# for each regressor's worth of of FIR's, concatenate them into a single 4D image
for i in $(seq 0 $(($NUM_REGRESSORS-1))); do
  first=${firsts[$i]}
  name=${regressor_names[$i]}
  last=$(echo "$first + $NUM_LAGS - 1" | bc)

  stat_file_path_format="$THIRDLEVEL_DIR/cope%g.gfeat/cope1.feat/$stat_file"

  seq --format "$stat_file_path_format" $first $last \
    | xargs fslmerge -t $output_dir/fir_$name.nii.gz
done
