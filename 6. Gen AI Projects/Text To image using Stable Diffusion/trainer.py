import os
import glob
import bitsandbytes as bnb
from typing import List, Dict
from PIL import Image
from tqdm.auto import tqdm

import torch
from torch import Tensor
import torch.nn.functional as F
import torch.utils.checkpoint
from transformers import AutoTokenizer, CLIPTextModel
from diffusers import (
    AutoencoderKL,
    DDPMScheduler,
    StableDiffusionPipeline,
    UNet2DConditionModel,
)

from data.dreambooth import DreamBoothDataModule


def dict_to_cuda(x: Dict[str, Tensor]) -> Dict[str, Tensor]:
    return {k: v.cuda() for k, v in x.items()}


def model_name_from_pretrain_id(pretrain_id: str) -> str:
    match pretrain_id:
        case "sd2-community/stable-diffusion-2":
            return "sd2"
        case _:
            raise ValueError(f"Unknown pretrain_id: {pretrain_id}")


class Trainer:

    def __init__(self, cfg):
        self.cfg = cfg
        self.seed = cfg.RANDOM.SEED

        self.pretrain_id = cfg.MODEL.PRETRAIN_ID
        self.with_prior_preservation = cfg.TRAINER.PRIOR_PRESERVATION.ENABLE
        self.prior_loss_weight = (
            cfg.TRAINER.PRIOR_PRESERVATION.LOSS_WEIGHT
            if self.with_prior_preservation
            else 0.0
        )

        name = f"{model_name_from_pretrain_id(self.pretrain_id)}/{cfg.DATA.SUBSET}-{self.prior_loss_weight}"

        self.ckpt_dir = f"runs/{name}/checkpoints"
        self.eval_dir = f"runs/{name}/results"
        os.makedirs(self.ckpt_dir, exist_ok=True)
        os.makedirs(self.eval_dir, exist_ok=True)

        torch.cuda.set_device(0)

        # tokenizer
        tokenizer = AutoTokenizer.from_pretrained(
            self.pretrain_id,
            subfolder="tokenizer",
            use_fast=False,
        )

        # datamodule
        self.datamodule = DreamBoothDataModule(
            tokenizer,
            cfg.DATA.ROOT,
            cfg.DATA.NAME,
            cfg.DATA.SUBSET,
            cfg.DATA.TEST_PROMPT_FNAME,
            train_batch_size=cfg.DATA.TRAIN_BATCH_SIZE,
            instance_prompt_template=cfg.DATA.INSTANCE_PROMPT_TEMPLATE,
            class_prompt_template=cfg.DATA.CLASS_PROMPT_TEMPLATE,
            image_size=cfg.DATA.IMAGE_SIZE,
            num_workers=cfg.DATA.NUM_WORKERS,
            num_images_per_class=cfg.DATA.NUM_IMAGES_PER_CLASS,
            with_prior_preservation=self.with_prior_preservation,
        )

        if self.with_prior_preservation:
            print("Generating class images for prior preservation...")
            self.generate_class_images(
                f"{cfg.DATA.ROOT}/{cfg.DATA.NAME}/priors",
                class_prompt_template=cfg.DATA.CLASS_PROMPT_TEMPLATE,
                num_images_per_class=cfg.DATA.NUM_IMAGES_PER_CLASS,
            )

        self.num_epochs = cfg.TRAINER.NUM_EPOCHS
        self.max_train_steps = self.num_epochs * len(self.datamodule.train_loader)

        self.eval_freq = cfg.TRAINER.EVAL_FREQ
        self.max_grad_norm = cfg.TRAINER.MAX_GRAD_NORM
        self.weight_dtype = torch.float32
        self.lr = cfg.TRAINER.LR

        self.epoch_idx = -1

    # ============================================================
    # ======================== TRAINING ===========================
    # ============================================================

    def train(self):
        # 1. setup models
        self.noise_scheduler = DDPMScheduler.from_pretrained(
            self.pretrain_id, subfolder="scheduler"
        )

        self.text_encoder = CLIPTextModel.from_pretrained(
            self.pretrain_id, subfolder="text_encoder"
        ).cuda().to(dtype=self.weight_dtype)
        self.text_encoder.requires_grad_(False)

        self.vae = AutoencoderKL.from_pretrained(
            self.pretrain_id, subfolder="vae"
        ).cuda().to(dtype=self.weight_dtype)
        self.vae.requires_grad_(False)

        self.unet = UNet2DConditionModel.from_pretrained(
            self.pretrain_id, subfolder="unet"
        ).cuda().to(dtype=self.weight_dtype)
        self.unet.enable_gradient_checkpointing()

        # 2. optimizer
        self.trainable_params = self.unet.parameters()
        self.optimizer = bnb.optim.AdamW8bit(self.trainable_params, lr=self.lr)

        # 3. training
        for self.epoch_idx in tqdm(range(self.num_epochs)):
            for step, batch in enumerate(self.datamodule.train_loader):
                self.unet.train()
                self.forward_backward(batch)

            if (self.epoch_idx + 1) % self.eval_freq == 0:
                self.test()

        self.save_unet()

    # ============================================================
    # =================== FORWARD / BACKWARD ======================
    # ============================================================

    def forward_backward(self, batch: Dict[str, Tensor]):
        # 1. to cuda
        batch = dict_to_cuda(batch)

        # 2. encode images -> latents
        vae_out = self.vae.encode(batch["pixel_values"])
        latents = vae_out.latent_dist.sample()
        latents = latents * self.vae.config.scaling_factor  # sd2 = 0.18215

        # 3. noise
        noise = torch.randn_like(latents)

        # 4. random timestep
        bsz = latents.shape[0]
        timesteps = torch.randint(
            0, self.noise_scheduler.config.num_train_timesteps, (bsz,), device="cuda"
        ).long()

        # 5. noisy latents
        noisy_latents = self.noise_scheduler.add_noise(latents, noise, timesteps)

        # 6. text embeddings
        encoder_hidden_states = self.text_encoder(
            input_ids=batch["input_ids"],
            attention_mask=batch.get("attention_mask", None),
        ).last_hidden_state

        # 7. predict
        model_pred = self.unet(
            noisy_latents, timesteps, encoder_hidden_states
        ).sample

        # 8. target
        if self.noise_scheduler.config.prediction_type == "epsilon":
            target = noise
        elif self.noise_scheduler.config.prediction_type == "v_prediction":
            target = self.noise_scheduler.get_velocity(latents, noise, timesteps)
        else:
            raise ValueError("Unknown prediction type.")

        # 9a. prior loss
        if self.with_prior_preservation:
            model_pred, model_pred_prior = torch.chunk(model_pred, 2, dim=0)
            target, target_prior = torch.chunk(target, 2, dim=0)

            prior_loss = F.mse_loss(model_pred_prior, target_prior, reduction="mean")

        # 9b. reconstruction loss
        loss = F.mse_loss(model_pred, target, reduction="mean")

        # 9c. total loss
        if self.with_prior_preservation:
            loss = loss + self.prior_loss_weight * prior_loss

        # 10. optimize
        self.optimizer.zero_grad()
        loss.backward()
        torch.nn.utils.clip_grad_norm_(self.trainable_params, self.max_grad_norm)
        self.optimizer.step()

    # ============================================================
    # ======================== SAVE / LOAD ========================
    # ============================================================

    def save_unet(self):
        self.unet.save_pretrained(self.ckpt_dir)
        print(f"UNet saved state to {self.ckpt_dir}")

    def load_unet(self):
        self.unet = UNet2DConditionModel.from_pretrained(self.ckpt_dir)
        self.unet = self.unet.cuda().to(dtype=self.weight_dtype)
        self.unet.enable_gradient_checkpointing()
        print(f"UNet loaded state from {self.ckpt_dir}")

    # ============================================================
    # =========================== TEST ============================
    # ============================================================

    def test(self, num_validation_images: int = 5) -> List[Image.Image]:
        pipeline_cfg = {"unet": self.unet} if self.epoch_idx > 0 else {}
        pipeline = StableDiffusionPipeline.from_pretrained(
            self.pretrain_id, torch_dtype=self.weight_dtype, **pipeline_cfg
        )
        pipeline = pipeline.to("cuda")
        pipeline.set_progress_bar_config(disable=True)

        for name, prompt in self.datamodule.test_set:
            print(f"Running validation: generating {num_validation_images} images with prompt: {prompt}.")
            name = name.lower().replace(" ", "_")
            eval_dir = f"{self.eval_dir}/{name}"
            os.makedirs(eval_dir, exist_ok=True)

            generator = torch.Generator().manual_seed(self.seed)
            for i in range(num_validation_images):
                with torch.autocast("cuda"):
                    image = pipeline(
                        prompt=prompt, num_inference_steps=25, generator=generator
                    ).images[0]
                image.save(f"{eval_dir}/{self.epoch_idx + 1:04d}-{i:02d}.jpg")

        del pipeline
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

    # ============================================================
    # ================ CLASS IMAGE GENERATION =====================
    # ============================================================

    def generate_class_images(
        self,
        class_images_root: str,
        class_prompt_template: str,
        num_images_per_class: int,
    ) -> None:

        pipeline = StableDiffusionPipeline.from_pretrained(
            self.pretrain_id,
            torch_dtype=torch.float16,
            safety_checker=None,
        ).to("cuda")

        classes = self.datamodule.train_set.classes

        for class_ in classes:
            class_images_dir = os.path.join(class_images_root, class_)
            os.makedirs(class_images_dir, exist_ok=True)

            existing = len(glob.glob(f"{class_images_dir}/*.jpg"))
            need = num_images_per_class - existing

            if need > 0:
                prompt = class_prompt_template.format(class_.replace("_", " "))
                prompts = [prompt] * need
                print(f"Generating class images for {class_} with: {prompt}")
                images = pipeline(prompts).images
                for i, img in enumerate(images):
                    img.save(os.path.join(class_images_dir, f"{i:02d}.jpg"))

        del pipeline
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
