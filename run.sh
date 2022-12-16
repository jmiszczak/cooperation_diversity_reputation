#!/bin/bash
expName=${0/.sh/}
expName=${expName/./}
expName=${expName/\//}
echo "[INFO] Running experiment: " $expName
echo -n "[INFO] Start time: "
date +"%H:%M"
netlogo-headless.sh --threads 8 --model cooperation_diversity_reputation.nlogo --setup-file experiments.xml --table $expName.csv --experiment $expName
echo -n "[INFO] End time:"
date +"%H:%M"
.nlogo
