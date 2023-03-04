#!/bin/bash

sudo apt-get purge droplet-agent -y

curl -fsSL https://raw.githubusercontent.com/digitalocean/marketplace-partners/master/scripts/90-cleanup.sh | sudo bash
