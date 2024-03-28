#!/bin/bash

sudo yum update -y
sudo yum install -y python3 libssl-dev
# sudo amazon-linux-extras install ansible2
python3 -m pip install molecule ansible-core molecule-docker
sudo systemctl enable --now docker

export PATH="$HOME/.local/bin:PATH"