## Microsoft Azure

This appliance was created following https://github.com/Azure/azvmimagebuilder/tree/main/quickquickstarts/0_Creating_a_Custom_Linux_Managed_Image

### How to run this?
Simply clone this repo, go into this folder, run `curl -L https://aka.ms/InstallAzureCli | bash` to install az cli; alternatively follow https://documentation.ubuntu.com/azure/azure-how-to/instances/install-azure-cli/. Then run `sudo chmod +x build-vm.sh && ./build-vm.sh` (it should not take longer than 15min to build a new version)

### Ho to publish?

After the VM is running, log in to https://portal.azure.com, go to VM, click on the running VM, click on `Capture` and create an image from it with the settings below. (Tags do not need to get applied).

VM image settings:
![portal azure com_](https://user-images.githubusercontent.com/42591237/175539175-7f576ad8-2ae5-46e7-bf30-040908084e7f.png)

This is based on https://docs.microsoft.com/en-us/azure/marketplace/azure-vm-use-approved-base

Afterwards go to https://go.microsoft.com/fwlink/?linkid=2165935 to publish the image.

Then choose `Plan overview` -> click on `Nextcloud` -> choose `Technical details` -> there you can adjust the image. Afterwards click on `Save draft` -> review and submit
