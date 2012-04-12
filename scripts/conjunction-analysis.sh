#!/bin/bash -e

# Author: Alexa Tompary
# Last edited: 3/7/11

if [ $# -lt 4 ]; then
  echo "
usage: `basename $0` path/to/outputvol thresh path/to/stat_vol2 path/to/stat_vol1 path/to/stat_vol2 [path/to/statvol3] ...

This script runs a conjunction analysis on feat contrasts (in NIFTI format).
Enter the zstat volumes and the output volume with the nii.gz extension. Make
sure to include paths to each stat volume and also the output volume.
  "
  exit
fi

thresh=$2

outputdir=`dirname $1`

for ((statvol=3; statvol<=$# - 1; statvol++)); do
	nextvol=$((statvol + 1))
	if [ $statvol -eq 3 ]; then outputvol=${!statvol}; else outputvol=$1; fi
	for vol in $outputvol ${!nextvol}; do
		i=$(basename $vol)
		fslmaths $vol -recip ${outputdir}/recip_$i
		fslmaths ${outputdir}/recip_$i -abs ${outputdir}/recip_abs_$i 
		fslmaths ${outputdir}/recip_abs_$i -mul $vol ${outputdir}/sign_map_$i 	#get sign maps of each map
		fslmaths $vol -abs ${outputdir}/abs_$i 	#abs value of map, to be masked later
	done
	
	# multiply sign maps together to find voxels that share sign for each contrast, zero out all others
	fslmaths ${outputdir}/sign_map_$(basename $outputvol) -mul ${outputdir}/sign_map_$(basename ${!nextvol}) ${outputdir}/sign_map_combined
	fslmaths ${outputdir}/sign_map_combined -thr 0 ${outputdir}/sign_map_thr
	
	# get the lower intensity of the two contrasts (abs valued) for each voxel, and then threshold the map at the specified level
	fslmerge -t ${outputdir}/stats_concat ${outputdir}/abs_$(basename $outputvol) ${outputdir}/abs_$(basename ${!nextvol})
	fslmaths ${outputdir}/stats_concat.nii.gz -Tmin -thr $thresh ${outputdir}/stats_thr
	
	# revert back to original signs
	fslmaths ${outputdir}/stats_thr.nii.gz -mul ${outputdir}/sign_map_$(basename ${!nextvol}) $1
done

#clean up
rm -rf ${outputdir}/abs_* ${outputdir}/sign_map* ${outputdir}/stats_* ${outputdir}/recip_*
