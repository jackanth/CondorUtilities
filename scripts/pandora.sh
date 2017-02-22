#!/bin/bash

# Grab the input parameters.
pandoraLocation=$1
eventsPerFile=$2
setupScriptLocation=$3
geometryFile=$4
IN=$5

# The input XML file paths are @-separated, so turn them into an array.
arrIN=(${IN//@/ })

eval "source $setupScriptLocation" # in case setup script location has a ~

# Run Pandora for each XML file.
for j in `seq 0 $((${#arrIN[@]}-1))`
do
    eval "$pandoraLocation -i ${arrIN[$j]} -d $geometryFile -N -n $eventsPerFile > /dev/null"
done

exit

