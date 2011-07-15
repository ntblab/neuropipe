#!/bin/sh
# This script prints the total number of kilobytes of physical and swap memory
# that are available on this system
#
# Only for use on rondo, the lab workstations, or any other linux machine

set -e

PHYSICAL_MEMORY_TOP_LINE=4
SWAP_MEMORY_TOP_LINE=5
MEMORY_TOP_POSITION=2

# for each type of memory (physical or swap), we get the memory data, with top.
# select the line containing the memory count we care about, extract the KB
# count from that line, and then lop of the trailing 'k'.

physical_kbs=$(top -b -n 1 \
                 | sed -n "${PHYSICAL_MEMORY_TOP_LINE}p" \
                 | awk "{print \$$MEMORY_TOP_POSITION}" \
                 | sed s/k$//)

swap_kbs=$(top -b -n 1 \
             | sed -n "${SWAP_MEMORY_TOP_LINE}p" \
             | awk "{print \$$MEMORY_TOP_POSITION}" \
             | sed s/k$//)

echo "$physical_kbs + $swap_kbs" | bc
