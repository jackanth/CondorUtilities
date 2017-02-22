#!/bin/bash

# Example usage: `source scripts/runCondorBatch.sh "100" "batch_config.txt" 10 true "~anthony/LAr/pandora/LArReco/validation" "Validation.C" "~anthony/LAr/pandora/setup.sh" "false, false, 0, 100000, 5, 15, true, false, true"`

# Grab the input parameters.
eventsPerFile=$1
config_file=$2
xml_dir="xmls"
root_label="root"
root_dir="roots"
nFilesPerJob=$3
validate=$4
validation_directory=$5
validation_filename=$6
setupScriptLocation=$7
validation_args=$8
geometryFile=$9

echo "SETUP: $setupScriptLocation"

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

# For each row in the configuration file, except the header row, make an XML base file.
while IFS='' read -r line || [[ -n "$line" ]]; do
    if $firstTime ; then
        firstTime=false;
        continue;
    fi

    # Copy the master XML file into the base directory and use sed to make the replacements for each column.
    settingsFileLocation=$(echo $line | awk "NR==1{print \$2}")
    eval "cp $settingsFileLocation xml_bases/$batchCounter.xml" # settings file location could use a ~

    for i in `seq 4 $numColumns`; # column 1 is the pandora location, column 2 is the settings file to use, column 3 is the sample location, the rest are the replacements to make in the settings file
        do
            columnTitle=$(awk "NR==1{print \$$i}" $config_file)
            
            # Avoid wildcard expansion in sample location.
            set -f
            columnEntry=$(echo $line | awk "NR==1{print \$$i}")
            set +f

            sed -i.bak s/"£$columnTitle£"/$columnEntry/g xml_bases/$batchCounter.xml
            
        done  

    batchCounter=$((batchCounter+1))

largestBatchNumber=$((batchCounter-1))

done < "$config_file"

# Now run all the batch instances.
firstTimeHeader=true
batchCounter=0

while IFS='' read -r line || [[ -n "$line" ]]; do
    if $firstTimeHeader ; then
        firstTimeHeader=false;
        continue;
    fi

    pandoraLocation=$(echo $line | awk "NR==1{print \$1}")

    # Avoid wildcard expansion in sample location.
    set -f
    sampleLocation=$(echo $line | awk "NR==1{print \$3}")
    set +f

    source scripts/runCondorBatchInstance.sh $batchCounter "$pandoraLocation" "$eventsPerFile" "$sampleLocation" "${xml_dir}" "${root_label}" "${root_dir}" "${nFilesPerJob}" "${validate}" "${validation_directory}" "${validation_filename}" "${validation_args}" "$largestBatchNumber" "$setupScriptLocation" "$geometryFile"

    batchCounter=$((batchCounter+1))
    
done < "$config_file" 
