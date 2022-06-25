# The OVA build
It was unfortunately not possible to be automated. So the auto-build was reverted.

Now the build needs to be done manually but since AIO auto-updates itself, this is not so bad.

## How to build a new OVA?

1. Import this OVA into virtualbox: https://cloud.nextcloud.com/s/po5LMnwg6RzESJo
1. Log in using `ncadmin` as username and `nextcloud` as password
1. Run `curl -fsSL https://raw.githubusercontent.com/nextcloud-releases/all-in-one/main/.build/ova/build.sh | sudo bash`
1. Shut down the VM and export it using the default settings (but name the file and the product Nextcloud-AIO instead of Ubuntu-22.04)
1. Upload it to the download server (follow https://github.com/nextcloud-gmbh/sysadmin/issues/581#issuecomment-1165980150)
