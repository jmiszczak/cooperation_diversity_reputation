#!/bin/bash
# get the name of the experiment from the script
expName=${0/.sh/}
expName=${expName/./}
expName=${expName/\//}

# set the file contain the model 
modelFile=cooperation_spatial_diversity.nlogo

# set the file with experiment definitions
expFile=experiments.xml

# print some information
echo "[INFO] Running experiment: " $expName
echo -n "[INFO] Start time: "
date +"%d/%m - %H:%M"

# run NetLogo in the headless mode
# use 16 threads by default
# save results using table format
netlogo-headless.sh --threads 16 \
  --model $modelFile \
  --setup-file $expFile \
  --table $expName.csv \
  --experiment $expName

# print some information after finishing
echo -n "[INFO] End time: "
date +"%d/%m - %H:%M"
