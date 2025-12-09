#!/bin/sh
# TODO
DEVICE=${1:-"0"}

ARTISTS=(
    "vincent-van-gogh"
    "claude-monet"
    "pablo-picasso"
)

for ARTIST in "${ARTISTS[@]}"; do
    CUDA_VISIBLE_DEVICES=$DEVICE python3 main.py \
        -c configs/wikiart.yaml \
        DATA.SUBSET $ARTIST \
        TRAINER.PRIOR_PRESERVATION.ENABLE False

    CUDA_VISIBLE_DEVICES=$DEVICE python3 main.py \
        -c configs/wikiart.yaml \
        DATA.SUBSET $ARTIST \
        TRAINER.PRIOR_PRESERVATION.ENABLE True \
        TRAINER.PRIOR_PRESERVATION.LOSS_WEIGHT 1.0
done
