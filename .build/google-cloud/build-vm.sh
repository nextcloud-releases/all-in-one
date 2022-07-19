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

#
# Configure service account based on https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/packer/examples/gce
#

# export PROJECT_ID=nextcloud-aio
# export PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")

# gcloud iam service-accounts create packer --description "Packer image builder"

# gcloud projects add-iam-policy-binding $PROJECT_ID \
#   --role="roles/compute.instanceAdmin.v1" \
#   --member="serviceAccount:packer@${PROJECT_ID}.iam.gserviceaccount.com"
# gcloud projects add-iam-policy-binding $PROJECT_ID \
#   --role="roles/iam.serviceAccountUser" \
#   --member="serviceAccount:packer@${PROJECT_ID}.iam.gserviceaccount.com"

# gcloud iam service-accounts add-iam-policy-binding \
#   packer@${PROJECT_ID}.iam.gserviceaccount.com \
#   --role="roles/iam.serviceAccountTokenCreator" \
#   --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

gcloud builds submit .
