from torch.utils.data import Dataset
import torchvision.transforms as T
import os
import random
import glob
from PIL import Image
import pandas as pd
import numpy as np


class PokemonDataset(Dataset):

    def __init__(
        self,
        dataroot: str,
        subset: str,
        tokenizer,
        instance_prompt_template: str,
        class_prompt_template: str,
        num_images_per_class: int = None,
        image_size: int = 512,
        with_prior_preservation: bool = False,
    ):
        self.size = image_size
        self.tokenizer = tokenizer

        self.dataroot = dataroot

        self.num_class_images = num_images_per_class
        self.instance_prompt_template = instance_prompt_template
        self.class_prompt_template = class_prompt_template

        self.image_transforms = T.Compose(
            [
                T.Resize(image_size, interpolation=T.InterpolationMode.BILINEAR),
                T.RandomCrop(image_size),
                T.ToTensor(),
                T.Normalize([0.5], [0.5]),
            ]
        )

        dataframe = pd.read_csv(
            os.path.join(self.dataroot, 'data/pokemon.csv'),
            delimiter='\t', encoding='utf-16',
        )
        self.dataset = []
        self.classes = []
        assert (subset[:4] == 'gen-')
        for _, row in enumerate(dataframe.itertuples(index=False)):
            if row.gen != subset[4:]:
                continue
            fname = os.path.join(self.dataroot, f'images/large_images/{row.national_number:03d}.png')
            if not os.path.exists(fname):
                continue
            if row.secondary_type is np.nan:
                poketype = row.primary_type
            else:
                poketype = f'{row.primary_type}-{row.secondary_type}'
            class_ = '_'.join(row.classification.split()[:-1]).lower()
            self.dataset.append({
                'fname': fname,
                'name': row.english_name,
                'type': poketype,
                'cls': class_,
            })
            if class_ not in self.classes:
                self.classes.append(class_)

        self.with_prior_preservation = with_prior_preservation

    def __len__(self):
        return len(self.dataset)

    def __getitem__(self, index):
        example = {}
        item = self.dataset[index]
        instance_image_fname = item['fname']
        class_ = item['cls']

        instance_image = Image.open(instance_image_fname)
        instance_image = instance_image.convert("RGB")
        example["instance_images"] = self.image_transforms(instance_image)

        instance_prompt = self.instance_prompt_template.format(class_.replace('_', ' '))
        instance_text_inputs = self.tokenizer(
            instance_prompt,
            truncation=True,
            padding="max_length",
            max_length=self.tokenizer.model_max_length,
            return_tensors="pt",
        )
        example["instance_prompt_ids"] = instance_text_inputs.input_ids
        example["instance_attention_mask"] = instance_text_inputs.attention_mask

        if self.with_prior_preservation:
            class_image_fname = random.choice(
                glob.glob(f"{self.dataroot}/priors/{class_}/*.jpg")[:self.num_class_images])
            class_image = Image.open(class_image_fname).convert("RGB")
            example["class_images"] = self.image_transforms(class_image)

            class_prompt = self.class_prompt_template.format(class_.replace('_', ' '))
            class_text_inputs = self.tokenizer(
                class_prompt,
                truncation=True,
                padding="max_length",
                max_length=self.tokenizer.model_max_length,
                return_tensors="pt",
            )

            example["class_prompt_ids"] = class_text_inputs.input_ids
            example["class_attention_mask"] = class_text_inputs.attention_mask

        # print(instance_image_fname, instance_prompt)
        # print(class_image_fname, class_prompt)

        return example
