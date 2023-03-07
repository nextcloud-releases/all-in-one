#!/bin/bash

set -x

#
# 1. Pre-requirements
#

# Install az cli
# only needs to be done once:
# curl -L https://aka.ms/InstallAzureCli | bash

# Sign in (if not already done)
if ! az account show &>/dev/null; then
  az login
fi

#
# Register feature (if not already done)
#

# az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview

# az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview | grep state

# az feature show --namespace Microsoft.KeyVault --name VirtualMachineTemplatePreview | grep state

# # wait until it says registered

# # check you are registered for the providers

# az provider show -n Microsoft.Compute -o json | grep registrationState
# az provider show -n Microsoft.Storage -o json | grep registrationState
# az provider show -n Microsoft.KeyVault -o json | grep registrationState
# az provider show -n Microsoft.VirtualMachineImages -o json | grep registrationState
# az provider show -n Microsoft.Network -o json | grep registrationState

# # Register them if not present

# az provider register -n Microsoft.VirtualMachineImages
# az provider register -n Microsoft.Compute
# az provider register -n Microsoft.KeyVault
# az provider register -n Microsoft.Storage
# az provider register -n Microsoft.Network

#
# Set Permissions & Create Resource Group for Image Builder Images
#

# set your environment variables here!!!!

# destination image resource group
export imageResourceGroup=nextcloud-aio-build

# location (see possible locations in main docs)
export location=westeurope

# your subscription
# get the current subID : 'az account show | grep id'
export subscriptionID=$(az account show | grep id | tr -d '",' | cut -c7-)

# name of the image to be created
export imageName=nextcloud-aio-image

# image distribution metadata reference name
export runOutputName=nextcloudAioImg01ro

# create resource group
az group create -n $imageResourceGroup -l $location

#
# Create User-Assigned Managed Identity and Grant Permissions
#

# create user assigned identity for image builder to access the storage account where the script is located
export identityName=nextcloud-aio-$(date +'%s')
az identity create -g $imageResourceGroup -n $identityName

# get identity id
export imgBuilderCliId=$(az identity show -g $imageResourceGroup -n $identityName | grep "clientId" | cut -c16- | tr -d '",')

# get the user identity URI, needed for the template
export imgBuilderId=/subscriptions/$subscriptionID/resourcegroups/$imageResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$identityName

# download preconfigured role definition example
rm -f aibRoleImageCreation.json
curl https://raw.githubusercontent.com/Azure/azvmimagebuilder/main/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json -o aibRoleImageCreation.json

export imageRoleDefName="Azure Image Builder Image Def"$(date +'%s')

# update the definition
sed -i -e "s/<subscriptionID>/$subscriptionID/g" aibRoleImageCreation.json
sed -i -e "s/<rgName>/$imageResourceGroup/g" aibRoleImageCreation.json
sed -i -e "s/Azure Image Builder Service Image Creation Role/$imageRoleDefName/g" aibRoleImageCreation.json

# create role definitions
az role definition create --role-definition ./aibRoleImageCreation.json

# Wait until it is created (no check possible)
sleep 1m

# grant role definition to the user assigned identity
az role assignment create \
    --assignee $imgBuilderCliId \
    --role "$imageRoleDefName" \
    --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup

#------------------------------------------------------------

sleep 2m

#
# 2. Modify HelloImage Example
#

# download the example and configure it with your vars
sed -i -e "s/<subscriptionID>/$subscriptionID/g" image-build.json
sed -i -e "s/<rgName>/$imageResourceGroup/g" image-build.json
sed -i -e "s/<region>/$location/g" image-build.json
sed -i -e "s/<imageName>/$imageName/g" image-build.json
sed -i -e "s/<runOutputName>/$runOutputName/g" image-build.json

sed -i -e "s%<imgBuilderId>%$imgBuilderId%g" image-build.json

#------------------------------------------------------------

#
# 3. Create the image
#

export IMAGE_BUILD_NUMBER=$(date +'%s')

# submit the image confiuration to the VM Image Builder Service

az resource create \
    --resource-group $imageResourceGroup \
    --properties @image-build.json \
    --is-full-object \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n image-build-$IMAGE_BUILD_NUMBER

# wait approx 1-3mins, depending on external links
# sleep 3m

# start the image build

az resource invoke-action \
     --resource-group $imageResourceGroup \
     --resource-type  Microsoft.VirtualMachineImages/imageTemplates \
     -n image-build-$IMAGE_BUILD_NUMBER \
     --action Run 

# wait approx 15mins
# sleep 15m

#------------------------------------------------------------

#
# 4. Create the VM
#

az vm create \
  --resource-group $imageResourceGroup \
  --name nextcloudAioImgVm$IMAGE_BUILD_NUMBER \
  --admin-username ncadmin \
  --image $imageName \
  --location $location \
  --generate-ssh-keys

# and login...
# ssh ncadmin@<pubIp>

# Clean up

az resource delete \
    --resource-group $imageResourceGroup \
    --resource-type Microsoft.VirtualMachineImages/imageTemplates \
    -n image-build-$IMAGE_BUILD_NUMBER

# delete permissions asssignments, roles and identity
az role assignment delete \
    --assignee $imgBuilderCliId \
    --role "$imageRoleDefName" \
    --scope /subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup

az role definition delete --name "$imageRoleDefName"

az identity delete --ids $imgBuilderId

# Will delete the VM:
# az group delete -n $imageResourceGroup

# Revert git changes
git stash
