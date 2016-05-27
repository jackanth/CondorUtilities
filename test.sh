#!/bin/bash

# Usage: `source test.sh`

# Set the configurable parameters.
pandoraLocation="/usera/weston/bin/pandora"
eventsPerFile=100
configFile="batch_config.txt"
inputFileString="/r05/dune/mcproduction_v05_04_00/prodgenie_bnb_nu_uboone_100k/*_reco1.pndr"
settingsFileLabel="PandoraSettings_master"
nFilesPerJob=10
validate=true
validationDir="/usera/weston/LAr/pandora/LArReco/validation"
validationFileName="Validation.C"
validationArgs="false, false, 0, 100000, 5, 15, true, false, true"

# Run the batch script.
source scripts/runCondorBatch.sh "$pandoraLocation" "$eventsPerFile" "$configFile" "$inputFileString"  "$settingsFileLabel" "$nFilesPerJob" "$validate" "$validationDir" "$validationFileName" "$validationArgs"
