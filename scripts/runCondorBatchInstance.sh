#!/bin/bash

# Grab the input parameters.
instance_suffix=$1
pandoraLocation=$2
eventsPerFile=$3
source_dir=$4
xml_dir=$5
root_label=$6
root_dir=$7
nFilesPerJob=$8
validate=$9
validation_directory=${10}
validation_filename=${11}
validation_args=${12}
totalBatches=${13}
setupScriptLocation=${14}
recoOption=${15}

# Delete any existing ROOT and XML files.
rm -f roots/*
rm -f xmls/*

echo -e "[batch $instance_suffix/$totalBatches] \e[1;35mWriting xml files\e[0m"
source scripts/makeXml.sh "${source_dir}" "xml_bases/$instance_suffix.xml" "${xml_dir}" "${root_label}" "${root_dir}"

echo -e "[batch $instance_suffix/$totalBatches] \e[1;35mWriting run list\e[0m"
source scripts/makeRunList.sh "$pandoraLocation" "$eventsPerFile" "${instance_suffix}" "${source_dir}" "xml_bases/${instance_suffix}.xml" "${nFilesPerJob}" "$setupScriptLocation" "$recoOption" 

echo -e "[batch $instance_suffix/$totalBatches] \e[1;35mSubmitting condor jobs\e[0m"
python scripts/pandora_runCondor.py -r "runlist_$instance_suffix.txt"

echo -e "[batch $instance_suffix/$totalBatches] \e[1;35mWaiting for condor jobs\e[0m"

# While there are jobs still to be done, update the console output every 2 seconds.
jobsRemaining=$(condor_q | awk -F= 'END{ split($0,arr," "); print arr[1]  }')
while [ $jobsRemaining != 0 ]
do
    jobsRemaining=$(condor_q | awk -F= 'END{ split($0,arr," "); print arr[1]  }')
    echo -ne "\r\033[K > Jobs remaining: $jobsRemaining "
    sleep 2
done
echo -ne \\n

# Delete all the annoying ups files.
rm -f ups*

echo -e "[batch $instance_suffix/$totalBatches] \e[1;35mConcatenating ROOT files\e[0m"
echo -e " > This may take a while..."
rm -f catroots/$instance_suffix.root
hadd catroots/$instance_suffix.root roots/*.root >/dev/null

if $validate ; then
    echo -e "[batch $instance_suffix/$totalBatches] \e[1;35mRunning validation script and storing stdout\e[0m"
    echo -e " > This may take a while..."
    rm -f results/$instance_suffix.txt
    cwd=$(pwd)
    eval "cd $validation_directory" # in case validation directory contains a ~
    echo  -e "gROOT->ProcessLine(\".L $validation_filename+\"); Validation(\"$cwd/catroots/$instance_suffix.root\"); gSystem->Exit(0);" | root -b -l > $cwd/results/$instance_suffix.txt
    # echo  -e "gROOT->ProcessLine(\".L $validation_filename+\"); Validation(\"$cwd/catroots/$instance_suffix.root\", $validation_args); gSystem->Exit(0);" | root -b -l > $cwd/results/$instance_suffix.txt
    cd $cwd
fi

echo -e "[batch $instance_suffix/$totalBatches] \e[1;32mBatch $instance_suffix/$totalBatches completed successfully\e[0m"

