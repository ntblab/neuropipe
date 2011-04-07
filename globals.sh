#!/bin/bash -e
# author: mgsimon@princeton.edu
# this script sets up global variables for the whole project

set -e # stop immediately when an error occurs


# add necessary directories to the system path
PATH=$PATH:/exanet/ntb/packages/php-5.3.2/sapi/cli  # this is for rondo until php is installed


PROJECT_DIR=$(pwd)
SUBJECTS_DIR=subjects
GROUP_DIR=group

function exclude {
  for subj in $1; do
    if [ -e $SUBJECTS_DIR/$subj/EXCLUDED ]; then continue; fi
    echo $subj
  done
}

if [ -d $SUBJECTS_DIR ]; then
ALL_SUBJECTS=$(ls -1d $SUBJECTS_DIR/*/ | cut -d / -f 2)
NON_EXCLUDED_SUBJECTS=$(exclude "$ALL_SUBJECTS")
fi
