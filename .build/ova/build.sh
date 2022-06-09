#!/usr/bin/bash

# Install docker
curl -fsSL get.docker.com | sudo sh

# Adjust permissions
sudo mkdir -p /mnt/ncdata
sudo chown -R 33:0 /mnt/ncdata

# Install Nextcloud
sudo docker run -d \
--name nextcloud-aio-mastercontainer \
--restart always \
-p 80:80 \
-p 8080:8080 \
-p 8443:8443 \
-e NEXTCLOUD_MOUNT=/mnt/ \
-e NEXTCLOUD_DATADIR=/mnt/ncdata \
--volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
--volume /var/run/docker.sock:/var/run/docker.sock:ro \
nextcloud/all-in-one:latest

# Some Info
cat << EOF > /etc/motd

 #    #  ######  #    #   #####   ####   #        ####   #    #  #####
 ##   #  #        #  #      #    #    #  #       #    #  #    #  #    #
 # #  #  #####     ##       #    #       #       #    #  #    #  #    #
 #  # #  #         ##       #    #       #       #    #  #    #  #    #
 #   ##  #        #  #      #    #    #  #       #    #  #    #  #    #
 #    #  ######  #    #     #     ####   ######   ####    ####   #####

If you point a domain to this server, open port 8443 and 80 you can open the admin interface at https://yourdomain.com:8443
Otherwise you can open the admin interface at https://$(hostname -I | cut -f1 -d' '):8080
    
Further documentation is available here: https://github.com/nextcloud/all-in-one

EOF

# Cleanup
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -o Dpkg::Options::="--force-confold" upgrade -q -y --force-yes
apt-get -y autoremove
apt-get -y autoclean
rm -rf /tmp/* /var/tmp/*
history -c
cat /dev/null > /root/.bash_history
unset HISTFILE
find /var/log -mtime -1 -type f -exec truncate -s 0 {} \;
rm -rf /var/log/*.gz /var/log/*.[0-9] /var/log/*-????????
rm -rf /var/lib/cloud/instances/*
rm -f /root/.ssh/authorized_keys 
# rm -f /etc/ssh/*key*
touch /etc/ssh/revoked_keys
chmod 600 /etc/ssh/revoked_keys
