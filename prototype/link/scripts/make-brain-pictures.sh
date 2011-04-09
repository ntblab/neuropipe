#!/bin/bash
# author: mgsimon@princeton.edu

source globals.sh

if [ $# -ne 1 ]; then
  echo "
usage: `basename $0` anatomical_file

makes images out of every slice in the given anatomical_file and places them
in data/brainpics

REQUIREMENTS:
 - the environment var MAGICK_HOME must give the path to an ImageMagick install
 - BXH XCEDE tools must be installed and on the path
  "
  exit
fi


anatomical=$1

source globals.sh

if [ -d data/brainpics ]; then
  read -t 5 -p "brain pics have already been created. overwrite? (y/N) " overwrite || true
  if [ "$overwrite" != "y" ]; then exit; fi
  rm -rf data/brainpics
fi

mkdir -p data/brainpics

#pgmfile=test.pgm
pgmfile=$(mktemp -t pics).pgm
pngfile=data/brainpics/brain.png


bxh2pgm $anatomical $pgmfile
convert $pgmfile $pngfile


rm -f $pgmfile
