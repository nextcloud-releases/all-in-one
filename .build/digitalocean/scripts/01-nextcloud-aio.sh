#!/usr/bin/bash

# Install docker
curl -fsSL get.docker.com | sudo sh

# Adjust permissions
sudo mkdir -p /mnt/ncdata
sudo chown -R 33:0 /mnt/ncdata

# Some Info
cat << EOF > /etc/motd
 #    #  ######  #    #   #####   ####   #        ####   #    #  #####
 ##   #  #        #  #      #    #    #  #       #    #  #    #  #    #
 # #  #  #####     ##       #    #       #       #    #  #    #  #    #
 #  # #  #         ##       #    #       #       #    #  #    #  #    #
 #   ##  #        #  #      #    #    #  #       #    #  #    #  #    #
 #    #  ######  #    #     #     ####   ######   ####    ####   #####

If you point a domain to this server (\$(hostname -I | cut -f1 -d' ')), you can open the admin interface at https://yourdomain.com:8443
Otherwise you can open the admin interface at https://\$(hostname -I | cut -f1 -d' '):8080
    
Further documentation is available here: https://github.com/nextcloud/all-in-one

EOF
