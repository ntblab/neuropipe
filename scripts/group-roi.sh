#!/bin/bash
# author: mason simon (mgsimon@princeton.edu)

set -e

if [ $# -ne 0 ]; then
  echo "
usage: `basename $0`

This script runs a a group-level roi analysis. It concatenates the Rdat file in
each subject's results directory and runs several analyses:

-plots the mean fir for each roi
-plots each subject's fir for each roi
-calculates any non-zero lags and plots their PEs
-tests for hemisphere interaction

No arguments are needed to run the command, but remember to fill out the needed
project variables in globals.sh. Several of them are needed to run this analysis.

  "
  exit
fi

source globals.sh

mkdir -p $ROI_RESULTS_DIR

R --slave --args $ROI_RESULTS_DIR $SUBJ_ROI_DIR $NON_EXCLUDED_SUBJECTS < scripts/group-roi.r
