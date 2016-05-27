#!/bin/bash

source /usera/weston/LAr/pandora/setup.sh

# Grab the input parameters.
pandoraLocation=$1
eventsPerFile=$2
IN=$3

# The input XML file paths are @-separated, so turn them into an array.
arrIN=(${IN//@/ })

# Run Pandora for each XML file.
for j in `seq 0 ${#arrIN[@]}`
do
    eval "$pandoraLocation -i ${arrIN[$j]} -d uboone -N -n $eventsPerFile > /dev/null"
done

exit

