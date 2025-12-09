
# **Artist Style Fine-Tuning Framework**

This project provides a complete training pipeline for **fine-tuning Stable Diffusion** models on custom artistic styles using a DreamBooth-inspired approach.
It supports **perspective**, **style preservation**, and **prior-preservation** workflows, with configurable pipelines for both **artists** and **Pokémon-style** datasets.

---

## **1. Overview**

This repository enables:

* Fine-tuning Stable Diffusion on a specific artist’s style (e.g., Claude Monet).
* Prior-preservation training to prevent model overfitting.
* Perspective-based conditioning (optional).
* Automated generation and loading of prior images.
* Training for Pokémon datasets using the same standardized pipeline.

The codebase is modular, reproducible, and entirely configuration-driven through YAML files.

---

## **2. Folder Structure**

Your working directory looks like this:

```
starter_code/
│   main.py                 # Main training entry point
│   trainer.py              # Core training loop
│   README.md               # Documentation
│
├── configs/                # YAML configs (artists + pokemon)
│       artists_with_perspective_with_preservation.yaml
│       artists_without_perspective_with_preservation.yaml
│       ...
│
├── data/
│       artist_dataset.py   # Artist dataset loader
│       dreambooth.py       # DreamBooth-style utilities
│       pokemon_dataset.py  # Pokémon dataset loader
│       artists.txt
│       pokemon.txt
│
├── datasets/
│   ├── artists/
│   │   ├── claude-monet/                 # User-provided training images
│   │   └── priors/
│   │       └── claude-monet/             # Auto-generated prior images
│   │
│   └── pokedex/                          # Pokémon dataset
│       ├── gen-I/class_images
│       ├── gen-I/instance_images
│       └── images/large_images
│
├── utils/
│       config_helper.py
│       eval_helper.py
│       misc_helper.py
│
└── scripts/               # Optional shell scripts for training
        interactive.sh
        pokemon.sh
        wikiart.sh
```

---

## **3. How the Pipeline Works**

### **Step 1 — Provide Training Images**

Place your artist images here:

```
datasets/artists/<artist-name>/
```

Example:

```
datasets/artists/claude-monet/
```

### **Step 2 — Prior-Preservation Images (Optional but Recommended)**

If `use_prior_preservation: True` in YAML, the system:

* checks the folder
* auto-generates prior images into:

```
datasets/artists/priors/<artist-name>/
```

These priors help the model **retain general visual knowledge** while learning the new style.

### **Step 3 — Choose a YAML Config**

Artists example:

```
configs/artists_with_perspective_with_preservation.yaml
```

Pokémon example:

```
configs/pokemon_with_perspective_with_preservation.yaml
```

---

## **4. Running Training**

From project root:

```
python main.py --config configs/<config-file>.yaml
```

Example:

```
python main.py --config configs/artists_with_perspective_with_preservation.yaml
```

---

## **5. Key Features**

### **✔ Fine-Tuning Pretrained Stable Diffusion**

Uses DreamBooth-style optimization and attention layer updates.

### **✔ Prior Preservation**

Balances learning style vs retaining model generality.

### **✔ Perspective Conditioning (Optional)**

Allows models to learn spatial structure and depth continuity.

### **✔ Configurable Training**

Every feature (batch size, image size, LR, prior-preservation, perspective) is controllable via YAML.

### **✔ Modular Dataset Loaders**

Separated logic for:

* Artists
* Pokémon
* Prior images
* Instance images

### **✔ Auto Directory Handling**

No manual changes needed inside code; correct folder structure is sufficient.

---

## **6. Outputs**

After training, you receive:

* Fine-tuned model checkpoints
* Generated before/during/after images (15 per prompt)
* Prior images (if enabled)
* Logs for loss and training progress

The final model produces **consistent, high-fidelity generations** that match the target artist’s style.

---

## **7. Example Use Case**

Fine-tuning the style of **Claude Monet**:

* Upload 5–10 Monet paintings
* Enable prior-preservation
* Train using the artist-preservation YAML
* Compare **before**, **during**, and **after** results

This demonstrates how Stable Diffusion can be customized to reproduce domain-specific aesthetics without overfitting.

---

## **8. Extending the Project**

You can easily:

* Add new artists
* Add new Pokémon classes
* Adjust training configs
* Experiment with dataset mixing
* Replace Stable Diffusion checkpoints

The framework is designed to be **robust, scalable, and experiment-friendly**.

---

## **9. License**

This project is for research and educational purposes.

---

