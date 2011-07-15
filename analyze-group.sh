#!/bin/bash
#
# analyze.sh runs the analysis for an entire NeuroPipe project
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs

set -e # stop immediately when an error occurs


pushd $(dirname $0) > /dev/null   # move into the project's directory, quietly

source globals.sh   # load project-wide settings

# run each subject's analysis
for subj in $ALL_SUBJECTS; do
  bash $SUBJECTS_DIR/$subj/analyze.sh
done

# now, run group analyses

popd > /dev/null   # return to the directory this script was run from, quietly
