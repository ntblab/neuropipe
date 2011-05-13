#!/bin/bash -e

# Author: Alexa Tompary
# Last edited: 3/7/11

if [ $# -ne 4 ]; then
  echo "
usage: `basename $0` path/to/stat_vol1 path/to/stat_vol2 threshold path/to/output_vol

This script runs a conjunction analysis on two feat contrasts (in NIFTI format).
Enter the zstat volumes and the output volume with the nii.gz extension, and enter 
the feat directory where your stat volumes are located.
Your final volume will land in the same directory.
  "
  exit
fi

source globals.sh

vol1=$1
vol2=$2
thresh=$3
outputvol=$4

outputdir=`dirname $outputvol`

for statvol in $vol1 $vol2; do
	i=$(basename $statvol)
	#get sign maps of each contrast -- if there's an easier way to do it, please let me know!
	fslmaths $statvol -recip ${outputdir}/recip_$i
	fslmaths ${outputdir}/recip_$i -abs ${outputdir}/recip_abs_$i
	fslmaths ${outputdir}/recip_abs_$i -mul $statvol ${outputdir}/sign_map_$i
	#absolute value of contrasts, to be masked later
	fslmaths $statvol -abs ${outputdir}/abs_$i
done

#multiply sign maps together to find voxels that share sign for each contrast, zero out all others
fslmaths ${outputdir}/sign_map_$(basename $vol1) -mul ${outputdir}/sign_map_$(basename $vol2) ${outputdir}/sign_map
fslmaths ${outputdir}/sign_map.nii.gz -thr 0 ${outputdir}/sign_map_thr

#get the lower intensity of the two contrasts (abs valued) for each voxel, and then threshold the map at the requested level
fslmerge -t ${outputdir}/stats_concat ${outputdir}/abs_$(basename $vol1) ${outputdir}/abs_$(basename $vol2)
fslmaths ${outputdir}/stats_concat.nii.gz -Tmin ${outputdir}/stats_min
fslmaths ${outputdir}/stats_min.nii.gz -thr $thresh ${outputdir}/stats_thr

#revert back to original signs
fslmaths ${outputdir}/stats_thr.nii.gz -mul $vol1 $outputvol

#clean up
rm -rf ${outputdir}/abs_*
rm -rf ${outputdir}/sign_map*
rm -rf ${outputdir}/stats_*
rm -rf ${outputdir}/recip_*