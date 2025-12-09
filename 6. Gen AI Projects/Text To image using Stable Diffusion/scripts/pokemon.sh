#!/bin/sh
# TODO
DEVICE=${1:-"0"}

SUBSETS=(
    "gen-I"
    "gen-II"
)

for SUBSET in "${SUBSETS[@]}"; do
    CUDA_VISIBLE_DEVICES=$DEVICE python3 main.py \
        -c configs/pokemon.yaml \
        DATA.SUBSET $SUBSET \
        TRAINER.PRIOR_PRESERVATION.ENABLE False

    CUDA_VISIBLE_DEVICES=$DEVICE python3 main.py \
        -c configs/pokemon.yaml \
        DATA.SUBSET $SUBSET \
        TRAINER.PRIOR_PRESERVATION.ENABLE True \
        TRAINER.PRIOR_PRESERVATION.LOSS_WEIGHT 1.0 \
        TRAINER.LR 1.0e-5
done
