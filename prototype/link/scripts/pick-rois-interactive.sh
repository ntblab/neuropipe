#!/bin/bash -e


if [ $# -ne 4 ]; then
  echo "
usage: `basename $0` mean_functional_image stat_image region_name_file output_file

this script launches FSLView with the mean_functional_image and stat_image, and
then interactively prompts you to enter the x,y,z coordinates of the voxels with
peak activation in the regions listed--one per line--in region_name_file, in the
order they were listed in that file. it puts those coordinates into output_file.
  "
  exit
fi


mean_func_image=$1
stat_image=$2
region_name_file=$3
coords_file=$4


mkdir -p $(dirname $coords_file)
if [ -e $coords_file ]; then
  read -t 5 -p "coords file already exists. overwrite? (y/N) " overwrite || true
  if [ "$overwrite" != "y" ]; then exit; fi
  rm -f $coords_file
fi


fslview $mean_func_image $stat_image &


# read in regions
i=0
while read region; do
  regions["$i"]=$region
  i=($i+1)
done <$region_name_file


echo "enter the coordinates for each specified region in the order x, y, z, separating each by a space."
for region in "${regions[@]}"; do
  read -p "$region: " x y z
  echo "$x $y $z" >>$coords_file
done
echo "ok, you're done. close fslview now"

