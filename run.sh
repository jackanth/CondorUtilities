#!/bin/bash

# Usage: `source run.sh`

# Set the configurable parameters.
eventsPerFile=1000
configFile="config.txt"
setupScriptLocation="~anthony/LAr/pandora/setup.sh"

nFilesPerJob=3
validate=true
validationDir="~anthony/LAr/clean_pandora/LArReco/validation/"
validationFileName="Validation.C"
validationArgs="/* no args */"

# Run the batch script.
source scripts/runCondorBatch.sh "$eventsPerFile" "$configFile" "$nFilesPerJob" "$validate" "$validationDir" "$validationFileName" "$setupScriptLocation" "$validationArgs"
