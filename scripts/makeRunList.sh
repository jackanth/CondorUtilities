#!/bin/bash

# Example usage: `source makeRunList.sh "/usera/weston/bin/pandora" "100" "0" "/r05/dune/mcproduction_v05_04_00/prodgenie_bnb_nu_uboone_100k/*reco1.pndr" "PandoraSettings_master" "/usera/weston/LAr/condor/xmls" 10`

# Grab the input parameters
pandoraLocation=$1
eventsPerFile=$2
instance_suffix=$3
source_dir=$4
xml_label=$5
nFilesPerJob=$6

# Get rid of the runlist if it already exists.
rm -f "runlist_$instance_suffix.txt"

counter=0
fullCounter=0
firstTime=true

for i in `ls ${source_dir} | sort -V`
do
    fileIdentifier=$fullCounter # [`echo $i | grep -oP '(?<=_)\d+(?=_reco1\.)'`]
    fullCounter=$(expr $fullCounter + 1)

    # We only want to write the pandora binary location and number of events per file at the start of each job row.
    if { [ $counter -eq 0 ] && [ $firstTime == true ]; } || { [ $counter -eq 1 ] && [ $firstTime == false ]; };
    then
        echo -ne "$pandoraLocation $eventsPerFile " >> "runlist_$instance_suffix.txt"
    fi

    # Make the input configuration files strings @-separated (but we want no @ at the end).
    if [ $counter -eq $nFilesPerJob ];
    then
        echo -ne " > Writing: xmls/PandoraSettings_${fileIdentifier}.xml"\\r
        echo $(pwd)/xmls/PandoraSettings_${fileIdentifier}.xml >> "runlist_$instance_suffix.txt"
        counter=$(expr $counter - $nFilesPerJob)
        firstTime=false
    else
        echo -ne " > Writing: xmls/PandoraSettings_${fileIdentifier}.xml"\\r
        echo -n $(pwd)/xmls/PandoraSettings_${fileIdentifier}.xml@ >> "runlist_$instance_suffix.txt"

    fi
    counter=$(expr $counter + 1)

done
echo -ne \\n
