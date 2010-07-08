#!/bin/bash -e
# author: mgsimon@princeton.edu
# this script sets up global variables for the analysis of the current subject

set -e # stop immediately when an error occurs


# add necessary directories to the system path
export PATH=$PATH:/exanet/ntb/packages/bxh_xcede_tools/bin
export PATH=$PATH:/exanet/ntb/packages/psych-building-blocks/pipeline
export MAGICK_HOME=/exanet/ntb/packages/ImageMagick-6.5.9-9


SUBJ=<<SUBJECT_ID>>
PROJ_DIR=../../
SUBJECT_DIR=$PROJ_DIR/subjects/$SUBJ

RUNORDER_FILE=run_order.txt

SCRIPT_DIR=scripts
FSF_DIR=fsf
DICOM_ARCHIVE=data/raw.tar.gz
NIFTI_DIR=data/nifti
QA_DIR=data/qa
BEHAVIORAL_DATA_DIR=data/behavioral
FIRSTLEVEL_DIR=analysis/firstlevel
SECONDLEVEL_DIR=analysis/secondlevel
EV_DIR=design
BEHAVIORAL_OUTPUT_DIR=output/behavioral

