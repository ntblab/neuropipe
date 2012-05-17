#!/bin/bash
# this script expects to be run from the subject directory it's contained in.

set -e

if [ $# -lt 2 ]; then
  echo "
usage: `basename $0` scaling_factor path/to/feat_dir1 [path/to/feat_dir2] [path/to/feat_dir3]

This script runs a psc transform and gaussian filter on your roi coordinates,
and then extracts the time-locked stats for each coordinate in the space of the
specified run and loads them into R.

If you'd like to run this analysis for more than one functional run, add
the name of each run as an option to the command.

Note before beginning: be sure that you have filled out globals.sh with the
variables needed for this script. This includes:

-$ROI_COORDS_FILE, which should have a list of 3 column coordinates for the
	ROIs you're looking at
-$LOCALIZER_DIR, which is the path and name the run that you picked ROIs from
-$FIR_LAG, in a format starting at 0 -- if you have 18 lags, should look 
	like this -- 0:17
-$ROI_KERNEL_TYPE and $ROI_KERNEL_SIZE, which should be decided on based
	on the design/aims of your study

  "
  exit
fi

source globals.sh

function fir {
  feat_dir=$1
  output_dir=$2  

  mkdir -p $output_dir

  tmp_coords=$(mktemp -t tmp.XXXXXX)
  bash scripts/transform-coords-dest.sh $ROI_COORDS_FILE ${LOCALIZER_DIR} $feat_dir $tmp_coords

  stat_dir=$feat_dir/stats
  rm -f $stat_dir/cope*.psc.nii.gz
  rm -f $stat_dir/filtered_cope*.psc.nii.gz
  stat_files=$(seq --format "$stat_dir/cope%g.nii.gz" 1 `ls -l $stat_dir/cope*.nii.gz | wc -l`)
  for stat_file in $stat_files; do
    bn=$(basename $stat_file)
    stat_file_prefix=${bn%.nii.gz}
    psc_file=$stat_dir/$stat_file_prefix.psc.nii.gz
    filtered_psc_file=$stat_dir/filtered_$(basename $psc_file)

    if [ -f $psc_file ]; then
      echo "$psc_file already exists. skipping"
    else
      bash scripts/transform-to-psc.sh $stat_file $feat_dir/mean_func.nii.gz $feat_dir/mask.nii.gz $psc_file $scaling_factor
    fi
    if [ -f $filtered_psc_file ]; then
      echo "$filtered_psc_file already exists. skipping"
    else
      fslmaths $psc_file -kernel $ROI_KERNEL_TYPE $ROI_KERNEL_SIZE -fmean $filtered_psc_file
    fi
  done

stat_files=$(seq --format="$stat_dir/filtered_cope%g.psc.nii.gz" 1  `ls -l $stat_dir/filtered_cope*.nii.gz | wc -l`)

bash scripts/extract-stat-at-coords.sh "$stat_files" $tmp_coords >$output_dir/roi_coords.csv
 
}

mkdir -p $ROI_DIR
scaling_factor=$1

# number of runs as specified by input parameters
for run in "${@:2}"; do
	mkdir -p $ROI_DIR/`basename ${run%%.*}`
	fir $run $ROI_DIR/`basename ${run%%.*}`
done

