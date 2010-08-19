#!/bin/bash -e
# author: mgsimon@princeton.edu
# this script sets up global variables for the whole project

set -e # stop immediately when an error occurs


# add necessary directories to the system path
PATH=$PATH:/exanet/ntb/packages/php-5.3.2/sapi/cli  # this is for rondo until php is installed


PROJECT_DIR=$(pwd)
SUBJECTS_DIR=subjects
GROUP_DIR=group

ALL_SUBJECTS=$(ls -1d $SUBJECTS_DIR/*/ | cut --delimiter=/ --fields=2)

