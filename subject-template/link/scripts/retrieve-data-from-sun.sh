#!/bin/bash
# author: mgsimon@princeton.edu
#
# downloads raw DICOM data for the specified subject from sun and compresses it
# into a gzipped tar file at the file path specified by output_path


set -e # fail immediately on error


source globals.sh

tmp_dir="$(mktemp -d)"
data_dir=$tmp_dir/$subj
dicom_rename -patid $SUBJ -destdir $tmp_dir -prefix $SUBJ > /dev/null  #dicom_rename is noisy, so we redirect its stdout to /dev/null, where no one can hear you scream...
#mv $data_dir $DICOM_DIR

output_file=raw.tar.gz
output_dir=data
pushd $data_dir > /dev/null
tar --create --gzip --file=$output_file *
mv $data_dir/$output_file $(popd)/$output_dir

rm -rf $tmp_dir
