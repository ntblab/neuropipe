#!/bin/bash -e

# Author: Alexa Tompary
# Last edited: 3/7/11

if [ $# -ne 5 ]; then
  echo "
usage: `basename $0` stat_vol1 stat_vol2 threshold output_vol feat_directory

example: scripts/`basename $0` zstat2.nii.gz zstat4.nii.gz 2.3 conj_2-4.nii.gz analysis/firstlevel/localizer_hrf.feat/stats

This script runs a conjunction analysis on two feat contrasts (in NIFTI format).
Enter the zstat volumes and the output volume with the nii.gz extension, and enter 
the feat directory where your stat volumes are located.
Your final volume will land in the same directory.
  "
  exit
fi

source globals.sh

statvol1=$1
statvol2=$2
thresh=$3
outputvol=$4
featdir=$5

#statvol1=`basename $1`
#statvol2=`basename $2`

for i in $statvol1 $statvol2; do
	#get sign maps of each contrast -- if there's an easier way to do it, please let me know!
	fslmaths ${featdir}/$i -recip ${featdir}/recip_$i
	fslmaths ${featdir}/recip_$i -abs ${featdir}/recip_abs_$i
	fslmaths ${featdir}/recip_abs_$i -mul ${featdir}/$i ${featdir}/sign_map_$i
	#absolute value of contrasts, to be masked later
	fslmaths ${featdir}/$i -abs ${featdir}/abs_$i
done

#multiply sign maps together to find voxels that share sign for each contrast, zero out all others
fslmaths ${featdir}/sign_map_$statvol1 -mul ${featdir}/sign_map_$statvol2 ${featdir}/sign_map
fslmaths ${featdir}/sign_map.nii.gz -thr 0 ${featdir}/sign_map_thr

#get the lower intensity of the two contrasts (abs valued) for each voxel, and then threshold the map at the requested level
fslmerge -t ${featdir}/stats_concat ${featdir}/abs_$statvol1 ${featdir}/abs_$statvol2
fslmaths ${featdir}/stats_concat.nii.gz -Tmin ${featdir}/stats_min
fslmaths ${featdir}/stats_min.nii.gz -thr $thresh ${featdir}/stats_thr

#revert back to original signs
fslmaths ${featdir}/stats_thr.nii.gz -mul ${featdir}/$statvol1 ${featdir}/$outputvol