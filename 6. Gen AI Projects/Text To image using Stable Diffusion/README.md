# Assignment2: Text-to-image on personalized content
This assignment is modified from the HuggingFace DreamBooth [code](https://github.com/huggingface/diffusers/blob/main/examples/dreambooth/train_dreambooth.py).

## How to run?

### Interactive
```bash
bash scripts/wikiart.sh
bash scripts/pokemon.sh
```

- Each experiment can take about 3 hours. Please start early.

## Your TODOs
- Read the DreamBooth [paper](https://arxiv.org/abs/2208.12242).
- Understand the data module functions under `data`.
- In `trainer.py`,
    - implement the training function `trainer.forward_backward()` for the DreamBooth training.
- `configs`
    - Document your hyperparameters.
    - TIPS: You can experiment with different learning rate `TRAINER.LR` or different number of training epochs `TRAINER.EPOCH`
