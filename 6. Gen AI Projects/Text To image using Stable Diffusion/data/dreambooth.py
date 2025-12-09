import torch
from torch.utils.data import DataLoader

from data.artist_dataset import ArtistDataset
from data.pokemon_dataset import PokemonDataset


class DreamBoothDataModule:

    def __init__(
        self,
        tokenizer,
        dataroot: str,
        name: str,
        subset: str,
        test_prompt_fname: str,
        instance_prompt_template: str,
        class_prompt_template: str,
        train_batch_size: int = 1,
        image_size: int = 512,
        num_workers: int = 6,
        num_images_per_class: int = 5,
        with_prior_preservation: bool = False,
    ):
        # Dataset and DataLoaders creation:
        match name:
            case 'artists':
                DatasetClass = ArtistDataset
            case 'pokedex':
                DatasetClass = PokemonDataset
            case _:
                raise

        self.train_set = DatasetClass(
            dataroot=f"{dataroot}/{name}",
            subset=subset,
            instance_prompt_template=instance_prompt_template,
            class_prompt_template=class_prompt_template,
            num_images_per_class=num_images_per_class,
            tokenizer=tokenizer,
            image_size=image_size,
            with_prior_preservation=with_prior_preservation,
        )

        self.train_loader = DataLoader(
            self.train_set,
            batch_size=train_batch_size,
            shuffle=True,
            collate_fn=lambda examples: collate_fn(examples, with_prior_preservation=with_prior_preservation),
            num_workers=num_workers,
        )

        with open(test_prompt_fname, 'r') as f:
            lines = f.read().split('\n')
            self.test_set = [ line.split(': ') for line in lines ]


def collate_fn(examples, with_prior_preservation: bool):
    has_attention_mask = "instance_attention_mask" in examples[0]

    input_ids = [example["instance_prompt_ids"] for example in examples]
    pixel_values = [example["instance_images"] for example in examples]

    if has_attention_mask:
        attention_mask = [example["instance_attention_mask"] for example in examples]

    if with_prior_preservation:
        # Concat class and instance examples for prior preservation.
        # We do this to avoid doing two forward passes.
        input_ids += [example["class_prompt_ids"] for example in examples]
        pixel_values += [example["class_images"] for example in examples]

        if has_attention_mask:
            attention_mask += [example["class_attention_mask"] for example in examples]

    pixel_values = torch.stack(pixel_values)
    pixel_values = pixel_values.to(memory_format=torch.contiguous_format).float()

    input_ids = torch.cat(input_ids, dim=0)

    batch = {
        "input_ids": input_ids,
        "pixel_values": pixel_values,
    }

    if has_attention_mask:
        attention_mask = torch.cat(attention_mask, dim=0)
        batch["attention_mask"] = attention_mask

    return batch
