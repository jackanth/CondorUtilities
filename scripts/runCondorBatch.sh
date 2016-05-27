#!/bin/bash

# Example usage: `source scripts/runCondorBatch.sh "/usera/weston/bin/pandora" "100" "batch_config.txt" "/r05/dune/mcproduction_v05_04_00/prodgenie_bnb_nu_uboone_100k/*_reco1.pndr" "PandoraSettings_master" 10 true "/usera/weston/LAr/pandora/LArReco/validation" "Validation.C" "false, false, 0, 100000, 5, 15, true, false, true"`

# Grab the input parameters.
pandoraLocation=$1
eventsPerFile=$2
config_file=$3
source_dir=$4
xml_label=$5
xml_dir="xmls"
root_label="root"
root_dir="roots"
nFilesPerJob=$6
validate=$7
validation_directory=$8
validation_filename=$9
validation_args=${10}

# Check that hadd and root are accessible.
command -v hadd >/dev/null 2>&1 || { echo -e >&2 "\e[1;31mError: 'hadd' is required but is not currently accessible. Please setup uboonecode\e[0m"; return 1; }

if $validate ; then
    command -v hadd >/dev/null 2>&1 || { echo -e >&2 "\e[1;31mError: 'root' is required but is not currently accessible. Please setup uboonecode\e[0m"; return 1; }
fi

# Try to work out if we're in the right directory.
if [ ! -d scripts ]; then
    echo -e >&2 "\e[1;31mError: Could not see a 'scripts' folder. This script must be run from the 'condor' directory only\e[0m"; 
    return 1;
fi

# Make the required directories if they don't already exist.
mkdir -p roots xml_bases xmls results catroots log

# Delete any existing concatenated ROOT and base XML files--and any existing results.
rm -f catroots/*
rm -f xml_bases/*
rm -f results/*

echo -e "\e[1;35mWriting xml base files for all batches\e[0m"
echo -e " > This may take a while..."

# Get the number of columns in the configuration file.
numColumns=$(awk --field-separator=" " "{ print NF }" $config_file | uniq)

# Delete all the existing xml base files (and backups).
rm -f xml_bases/*.xml
rm -f xml_bases/*.bak

firstTime=true
batchCounter=0

# For each row in the configuration file, expect the header row, make an XML base file.
while IFS='' read -r line || [[ -n "$line" ]]; do
    if $firstTime ; then
        firstTime=false;
        continue;
    fi

    # Copy the master XML file into the base directory and use sed to make the replacements for each column.
    cp "$xml_label.xml" xml_bases/$batchCounter.xml

    for i in `seq 1 $numColumns`;
        do
            columnTitle=$(awk "NR==1{print \$$i}" $config_file)
            columnEntry=$(echo $line | awk "NR==1{print \$$i}")
            sed -i.bak s/"£%$columnTitle%£"/$columnEntry/g xml_bases/$batchCounter.xml
            
        done  

    batchCounter=$((batchCounter+1))

done < "$config_file"

# Now run all the batch instances.
for i in `seq 0 $((batchCounter-1))`;
    do
        source scripts/runCondorBatchInstance.sh $i "$pandoraLocation" "$eventsPerFile" "${source_dir}" "${xml_dir}" "${root_label}" "${root_dir}" "${nFilesPerJob}" "${validate}" "${validation_directory}" "${validation_filename}" "${validation_args}" "$((batchCounter-1))"
    done  
