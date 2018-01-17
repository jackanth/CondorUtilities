#!/bin/bash

# Usage: `source run.sh`

# Set the configurable parameters.
eventsPerFile=100
configFile="config.txt"
setupScriptLocation="~jjd49/lardirection_pandora/setup.sh"

nFilesPerJob=10
validate=false
validationDir="~jjd49/lardirection_pandora/LArReco/validation/"
validationFileName="Validation.C"
validationArgs="/* no args */"

# Run the batch script.
source scripts/runCondorBatch.sh "$eventsPerFile" "$configFile" "$nFilesPerJob" "$validate" "$validationDir" "$validationFileName" "$setupScriptLocation" "$validationArgs" 
