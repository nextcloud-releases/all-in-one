# The OVA build
It was unfortunately not possible to be automated. So the auto-build was reverted.

Now the build needs to be done manually but since AIO auto-updates itself, this is not so bad.

## How to build a new OVA?

1. Import this OVA into virtualbox: https://cloud.nextcloud.com/s/9LGNgMZqgaRqmTS
1. Set the network interface to bridged
1. Connect to the VM via its ip-address `ssh ncadmin@ip-address` (you can figure out the ip-address from console after login via `ip a`)
1. Log in using `ncadmin` as username and `nextcloud` as password
1. Run `curl -fsSL https://raw.githubusercontent.com/nextcloud-releases/all-in-one/main/.build/ova/build.sh | sudo bash`
1. Shut down the VM, switch the interface to NAT mode and export it using the default settings (but name the file and the product Nextcloud-AIO instead of Ubuntu-22.04)
1. Upload it to the download server (follow https://github.com/nextcloud-gmbh/sysadmin/issues/581#issuecomment-1165980150)
