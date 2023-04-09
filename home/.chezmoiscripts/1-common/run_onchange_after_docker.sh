#!/usr/bin/bash

set -eu

echo -e "==== Start: Docker ====\n"

sudo usermod -aG docker "$USER"

echo -e "\n==== End: Docker ===="
