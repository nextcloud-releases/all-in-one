#!/bin/bash

# Based on https://cloud.google.com/sdk/docs/install#linux
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-392.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-392.0.0-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh --usage-reporting false --path-update true --command-completion false --quiet
./google-cloud-sdk/bin/gcloud init
# log in with the marketplaces account
# choose to manage the nextcloud-aio project
# or manually with gcloud config set project nextcloud-aio
gcloud config set project nextcloud-aio

# All below is based on https://cloud.google.com/build/docs/building/build-vm-images-with-packer#yaml

#
# APIs aktivieren
#

# gcloud services enable sourcerepo.googleapis.com
# gcloud services enable compute.googleapis.com
# gcloud services enable servicemanagement.googleapis.com
# gcloud services enable storage-api.googleapis.com

#
# IAM permissions
#

# gcloud projects get-iam-policy nextcloud-aio --filter="(bindings.role:roles/cloudbuild.builds.builder)"  --flatten="bindings[].members" --format="value(bindings.members[])"

# gcloud projects add-iam-policy-binding nextcloud-aio \
#   --member serviceAccount:builder@nextcloud-aio.iam.gserviceaccount.com \
#   --role roles/compute.instanceAdmin

#
# Allow to run Packer commands
#

# git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git

# cd cloud-builders-community/packer

# gcloud builds submit .

gcloud builds submit --region="us-central1-a" --config [CONFIG_FILE_PATH] [SOURCE_DIRECTORY]