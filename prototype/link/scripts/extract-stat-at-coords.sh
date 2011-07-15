#!/bin/bash
# author: mgsimon@princeton.edu

set -e


if [ $# -ne 2 ]; then
  echo "
usage: `basename $0` stat_files roi_coords_file

prints a CSV file in which the element at row i and column j is the value in
the stat file specified by the i-th line of stat_files, at the coordinates
specified by the j-th line in roi_coords.
  "
  exit 1
fi


stat_files=$1
roi_coords_file=$2

sorted_stat_files=$(ls -rt $stat_files )

# print CSV header
printf "coordinates,"
for stat_file in $sorted_stat_files; do
  header=$(basename $stat_file)
  printf "%s," "$header"
done
printf "\n"

# print CSV body
cat $roi_coords_file | while read coords; do
  if [ ! -n "$coords" ]; then continue; fi
  printf "%s," "$coords"
  for stat_file in $sorted_stat_files; do
    value=$(fslmeants -i $stat_file -c $coords)
    printf "%s," "$value"
  done
  printf "\n"
done
