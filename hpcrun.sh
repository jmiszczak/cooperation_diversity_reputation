#!/usr/bin/bash
## job name
#SBATCH-J NetLogo
## grante name
#SBATCH -A plgopdyn0
## name of partition
#SBATCH -p plgrid-long
## number of cores
#SBATCH --ntasks-per-node=48
## file to which standard output will be redirected
#SBATCH --output="output.out"
## file to which the standard error stream will be redirected
#SBATCH --error="error.err

module load java
cd $SLURM_SUBMIT_DIR
echo "[INFO] Current directory:" `pwd`

NLBIN=/net/people/plgrid/plgjam/Software/NetLogo/6.3.0/netlogo-headless.sh
expDir=/net/people/plgrid/plgjam/Kuweta/cooperation_diversity_reputation

expName=cooperators-final-long-128

expCSV=$expDir/$expName.csv
# set the file with experiment definitions
expFile=$expDir/experiments.xml
# set the file contain the model 
modelFile=$expDir/cooperation_diversity_reputation.nlogo

# print some information
echo "[INFO] Running experiment: " $expName "on $(hostname)"
echo -n "[INFO] Start time: "
date +"%d/%m - %H:%M"

# run NetLogo in the headless mode
# save results using table format
$NLBIN --model $modelFile --setup-file $expFile --table $expCSV --experiment $expName

# print some information after finishing
echo -n "[INFO] End time:"
date +"%d/%m - %H:%M"
