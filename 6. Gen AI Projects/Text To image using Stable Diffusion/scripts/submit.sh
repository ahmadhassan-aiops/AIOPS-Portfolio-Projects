#!/bin/bash

sbatch --time=04:00:00 --nodes=1 --gpus-per-node=1 --exclude=scholar-g[000-003] --partition=scholar-gpu --account gpu ${@:1}