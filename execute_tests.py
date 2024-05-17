#!/usr/bin/env python3

import argparse
import subprocess
import json

with open(".vscode/launch.json", "r") as f:
    launch_config = json.load(f)
config_names = [config["name"] for config in launch_config["configurations"]]

parser = argparse.ArgumentParser(description="CLI for executing tests.")
parser.add_argument(
    "test_launcher_config", choices=config_names, help="choose one of %(choices)s"
)
args = parser.parse_args()


def obtain_config():
    return next(
        config
        for config in launch_config["configurations"]
        if config["name"] == args.test_launcher_config
    )


command = f"{obtain_config()['module']} {' '.join(obtain_config()['args'])}"

# Run tests
result = subprocess.run(command, shell=True, check=True)
