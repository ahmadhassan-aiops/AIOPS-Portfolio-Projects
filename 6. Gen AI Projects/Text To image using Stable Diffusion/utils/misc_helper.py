import torch
import numpy as np
import random


def set_random_seed(seed: int = 42) -> None:
    r"""
    Fix all random seed for reproducibility
    """
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    random.seed(seed)
