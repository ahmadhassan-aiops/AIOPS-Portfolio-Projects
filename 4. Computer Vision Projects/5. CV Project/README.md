# SproutCheck: plant seedlings, crop or weed

From one top-down photo of a seedling, name its species among 12 (three crops: maize, common wheat, sugar beet; nine
weeds) and say whether to keep it or remove it. EfficientNet-B0, fine-tuned from ImageNet weights, names **97.2%** of
713 held-out test photos correctly (macro F1 **0.969**), against 82.9% for frozen features with logistic regression;
only 3 of the 713 were a crop called a weed or the reverse. Exported to ONNX (16 MB), it runs on CPU in the app.

| | |
|---|---|
| **Live app** | [sproutcheck-seedling-classifier-application.streamlit.app](https://sproutcheck-seedling-classifier-application.streamlit.app/) |
| **App code** | [ahmadhassan-aiops/sproutcheck-seedling-classifier-application](https://github.com/ahmadhassan-aiops/sproutcheck-seedling-classifier-application) (training in `train.py`) |
| **Notebook** | [Seedling_Classification.ipynb](Seedling_Classification.ipynb) |
| **Model** | [model/](model): `sproutcheck.onnx` and `metadata.json` (classes, scores, calibration) |
| **Data** | `Labels.csv` here; `images.npy` (4,750 photos, 128 x 128, 233 MB) is not in git: it is the Aarhus University plant seedlings dataset (T. M. Giselsson et al., 2017) as a NumPy array. Place it next to the notebook to run it. |

The first version trained a small CNN from scratch on 64 x 64 images: 77% test accuracy on a 10% test set, and its
first model never named black-grass. The notebook explains what changed.
