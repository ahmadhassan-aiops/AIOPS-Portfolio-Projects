import argparse

from trainer import Trainer
from utils.misc_helper import set_random_seed
from utils.config_helper import get_config


def main() -> None:
    parser = argparse.ArgumentParser(description='Assignment 2')
    parser.add_argument(
        '-c', '--config',
        type=str, default='configs/pokemon.yaml',
        help='config file')
    parser.add_argument(
        'opts',
        default=None,
        nargs=argparse.REMAINDER,
        help='modify config options using the command-line',
    )
    args = parser.parse_args()
    cfg = get_config(args.config, args.opts)
    set_random_seed(cfg.RANDOM.SEED)
    trainer = Trainer(cfg)
    trainer.test()
    trainer.train()
    trainer.test()
    return


if __name__ == '__main__':
    main()
