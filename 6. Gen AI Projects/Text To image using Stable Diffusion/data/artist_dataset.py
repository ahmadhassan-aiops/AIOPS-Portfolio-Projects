from torch.utils.data import Dataset
import torchvision.transforms as T
import os
import random
import glob
from PIL import Image


class ArtistDataset(Dataset):

    classes = [
        "claude-monet"
     ]

    def __init__(
        self,
        dataroot: str,
        subset: str,
        tokenizer,
        instance_prompt_template: str,
        class_prompt_template: str,
        num_images_per_class=None,
        image_size=512,
        with_prior_preservation=False,
    ):
        self.dataroot = dataroot
        self.size = image_size
        self.tokenizer = tokenizer

        self.instance_image_fnames = glob.glob(f"{self.dataroot}/{subset}/*.jpg")
        self.class_data_dir = f"{self.dataroot}/priors"
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

        self.with_prior_preservation = with_prior_preservation

    def __len__(self):
        return len(self.instance_image_fnames)

    def __getitem__(self, index):
        example = {}
        instance_image_fname = self.instance_image_fnames[index]
        instance_image = Image.open(instance_image_fname).convert("RGB")
        example["instance_images"] = self.image_transforms(instance_image)

        class_ = os.path.basename(os.path.dirname(instance_image_fname))
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
            class_image_fname = random.choice(glob.glob(f"{self.class_data_dir}/{class_}/*")[:self.num_class_images])
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

        return example
