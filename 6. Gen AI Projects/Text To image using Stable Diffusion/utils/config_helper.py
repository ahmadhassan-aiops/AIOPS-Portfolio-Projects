from yacs.config import CfgNode as CN

_C = CN(new_allowed=True)

_C.RANDOM = CN(new_allowed=True)
_C.RANDOM.SEED = 42

_C.MODEL = CN(new_allowed=True)
_C.MODEL.PRETRAIN_ID = 'stabilityai/stable-diffusion-2'

_C.TRAINER = CN(new_allowed=True)
_C.TRAINER.PRIOR_PRESERVATION = CN(new_allowed=True)
_C.TRAINER.PRIOR_PRESERVATION.ENABLE = False
_C.TRAINER.PRIOR_PRESERVATION.LOSS_WEIGHT = 0.0


_C.TRAINER.NUM_EPOCHS = 10
_C.TRAINER.LR = 5.0e-6
_C.TRAINER.MAX_GRAD_NORM = 1.0
_C.TRAINER.NUM_VALIDATION_IMAGES = 4

_C.TRAINER.EVAL_FREQ = 5

_C.DATA = CN()
_C.DATA.ROOT = 'datasets'
_C.DATA.NAME = 'artists'
_C.DATA.SUBSET = 'vincent-van-gogh'
_C.DATA.IMAGE_SIZE = 512

_C.DATA.TEST_PROMPT_FNAME = 'data/artists.txt'
_C.DATA.INSTANCE_PROMPT_TEMPLATE = 'a purcs {}'
_C.DATA.CLASS_PROMPT_TEMPLATE = 'a {}'
_C.DATA.NUM_IMAGES_PER_CLASS = 1

_C.DATA.TRAIN_BATCH_SIZE = 2
_C.DATA.SAMPLE_BATCH_SIZE = 2
_C.DATA.TEST_BATCH_SIZE = 2
_C.DATA.NUM_WORKERS = 0


def get_config(filename: str, opts: list) -> CN:
    r"""
    Get CfgNode from config file and command line options
    """
    cfg = _C.clone()
    cfg.merge_from_file(filename)
    cfg.merge_from_list(opts)
    cfg.freeze()
    return cfg
