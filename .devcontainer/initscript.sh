#!/bin/bash
set -euo pipefail

if [ ! -f .env ]; then
    echo ".env file does not exist. Creating one now."
    echo -n "Enter git username: " && read -r git_user
    echo "GIT_USER=$git_user" >> .env
    echo -n "Enter git email: " && read -r git_email
    echo "GIT_EMAIL=$git_email" >> .env
    echo ".env file created with git variables."
else
    echo ".env file already exists. Skipping initialization of git variables."
fi