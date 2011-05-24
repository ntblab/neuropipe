#!/bin/bash
# author: Alexa Tompary

set -e  # fail immediately on error

if [ $# -ne 1 ]; then
  echo "
usage: `basename $0`  nifti_folder

re-orients your nifti volumes and bxh headers to LAS order.

BXH XCEDE tools must be in the path for this script to run.

see http://nifti.nimh.nih.gov/nifti-1 for details on NIfTi format.
see http://nbirn.net/tools/bxh_tools/index.shtm for details on BXH headers.
  "
  exit
fi


nifti_folder=$1

ORIENTATION=LAS

for bxh_file in `ls $nifti_folder/*.bxh`

	# reorient each scan
  scan_file=${nifti_folder}/`basename bxh_file%%.*`
  temp=$scan_file.old_orientation.bxh
  mv $scan_file $temp
  bxhreorient --orientation=$ORIENTATION $temp $scan_file 1>/dev/null 2>/dev/null
  rm -f $temp
  
	# reconvert the scan
  bxh2analyze -- overwrite --analyzetypes --niigz --niftihdr -s ${nifti_folder}/$scan_file.bxh ${nifti_folder}/$scan_file >/dev/null 2>/dev/null
end
  
  
    # code originally in convert-and-wrap-raw-data.sh
#  scan_file="${temp_output_dir}/${PREFIX}-$number.bxh"
#  temp=$scan_file.old_orientation.bxh
#  mv $scan_file $temp
#  bxhreorient --orientation=$ORIENTATION $temp $scan_file 1>/dev/null 2>/dev/null
#  rm -f $temp
