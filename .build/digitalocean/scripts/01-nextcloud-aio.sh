#!/usr/bin/bash

# Install docker
curl -fsSL get.docker.com | sudo sh

# Adjust permissions
sudo mkdir -p /mnt/ncdata
sudo chown -R 33:0 /mnt/ncdata

# Get Nextcloud AIO
sudo docker pull nextcloud/all-in-one:latest
