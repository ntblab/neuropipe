#!/bin/bash
set -e
source globals.sh

#Most of this script follows the advice of the following website,
#http://www.fmrib.ox.ac.uk/fsl/fugue/feat_fieldmap.html
#as well as Mark Pinsk's documentation.

#Set the names as you put them into your run order of the fieldmap magnitude and phase runs. Defaults are given:
FIELDMAP_MAG=fieldmap_mag
FIELDMAP_PHASE=fieldmap_phase

#Average the two fieldmap magnitude images (two are run for greater stability)
fslmaths $NIFTI_DIR/${SUBJ}_${FIELDMAP_MAG}.nii.gz -Tmean $NIFTI_DIR/${SUBJ}_${FIELDMAP_MAG}_mean.nii.gz

#BET extraction for resulting magnitude image
bet $NIFTI_DIR/${SUBJ}_${FIELDMAP_MAG}_mean.nii.gz $NIFTI_DIR/${SUBJ}_fieldmap_mag_mean_brain -B -R -f 0.4 #double-check that the BET parameters produce a decent brain extraction, may take some tweaking by trial & error

#Conversion to rad/sec and some smoothing for field map phase image (Skyra specific values):
# If the phase value ranges (fslstats fieldmap_phase01 -R) are 0 to +4094, use this commmand to convert to rad/s to get it to a range of -1277 to +1277:
fslmaths $NIFTI_DIR/${SUBJ}_${FIELDMAP_PHASE}.nii.gz -sub 2047.5 -mul 3.14159 -div 2047.5 -div 0.00246 $NIFTI_DIR/${SUBJ}_fieldmap_phase_radsec

fugue --loadfmap=$NIFTI_DIR/${SUBJ}_fieldmap_phase_radsec.nii.gz -s 2.0 --savefmap=$NIFTI_DIR/${SUBJ}_fieldmap_phase_radsec_sm2

