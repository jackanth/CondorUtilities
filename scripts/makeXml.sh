#!/bin/bash

# Example usage: `source makeXml.sh "/r05/dune/mcproduction_v05_04_00/prodgenie_bnb_nu_uboone_100k/*reco1.pndr" "PandoraSettings_master" "xmls" "root" "roots"`

# Grab the input parameters.
source_dir=$1
xml_label=$2
xml_dir=$3
root_label=$4
root_dir=$5

# Get rid of any existing xml files.
rm -f xmls/*.xml

counter=0
#max=1000
for i in `ls ${source_dir} | sort -V`
do
    #if [ $counter -gt $max ];
    #then
    #    break
    #fi

    # Get the file identifier and use this for the output root files.
    fileIdentifier=$counter # $[`echo $i | grep -oP '(?<=_)\d+(?=_reco1\.)'`]
    outputFile=$(pwd)/${root_dir}/${root_label}_$fileIdentifier.root;

    # Use sed to replace the INPUT_FILE_NAME and OUTPUT_FILE_NAME in the XML file with the right paths.
    sed -e s,INPUT_FILE_NAME,$i, -e s,OUTPUT_FILE_NAME,$outputFile, -e s,FILE_IDENTIFIER,$fileIdentifier, ${xml_label} > $(pwd)/${xml_dir}/PandoraSettings_${fileIdentifier}.xml

    counter=$[$counter+1]
    echo -ne " > Writing: ${xml_dir}/PandoraSettings_${fileIdentifier}.xml"\\r
done
echo -ne \\n
