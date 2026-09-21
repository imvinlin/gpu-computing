#!/bin/bash
#SBATCH --job-name=lab1_vecadd
#SBATCH --account=eel4930
#SBATCH --qos=eel4930
#SBATCH --partition=hpg-turin
#SBATCH --gpus=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --time=00:15:00
#SBATCH --output=lab1_%j.out

module purge
module load cuda

cd "$SLURM_SUBMIT_DIR"
make clean
make report
