#!/bin/bash

# Function to show text in green
print_green() {
    local TEXT="$1"
    printf "%b%s%b\n" "\e[0;92m" "$TEXT" "\e[0m"
}

# Check if socket is available and readable
if ! [ -a "/var/run/docker.sock" ]; then
    echo "Docker socket is not available. Cannot continue."
    exit 1
elif ! mountpoint -q "/mnt/docker-aio-config"; then
    echo "/mnt/docker-aio-config is not a mountpoint. Cannot proceed!"
    exit 1
elif ! sudo -u www-data test -r /var/run/docker.sock; then
    echo "Trying to fix docker.sock permissions internally..."
    DOCKER_GROUP=$(stat -c '%G' /var/run/docker.sock)
    DOCKER_GROUP_ID=$(stat -c '%g' /var/run/docker.sock)
    # Check if a group with the same group id of /var/run/docker.socket already exists in the container
    if grep -q "^$DOCKER_GROUP:" /etc/group; then
        # If yes, add www-data to that group
        echo "Adding internal www-data to group $DOCKER_GROUP"
        usermod -aG "$DOCKER_GROUP" www-data
    else
        # If the group doesn't exist, create it
        echo "Creating docker group internally with id $DOCKER_GROUP_ID"
        groupadd -g "$DOCKER_GROUP_ID" docker
        usermod -aG docker www-data
    fi
    if ! sudo -u www-data test -r /var/run/docker.sock; then
        echo "Docker socket is not readable by the www-data user. Cannot continue."
        exit 1
    fi
fi

# Check if api version is supported
API_VERSION_FILE="$(find ./ -name DockerActionManager.php | head -1)"
API_VERSION="$(grep -oP 'const API_VERSION.*\;' "$API_VERSION_FILE" | grep -oP [0-9]+.[0-9]+ | head -1)"
API_VERSION_NUMB="$(echo "$API_VERSION" | sed 's/\.//')"
LOCAL_API_VERSION_NUMB="$(curl -s --unix-socket /var/run/docker.sock http://"$API_VERSION"/version | sed 's/,/\n/g' | grep ApiVersion | grep -oP [0-9]+.[0-9]+ | head -1 | sed 's/\.//')"
if [ -n "$LOCAL_API_VERSION_NUMB" ] && [ -n "$API_VERSION_NUMB" ]; then
    if ! [ "$LOCAL_API_VERSION_NUMB" -ge "$API_VERSION_NUMB" ]; then
        echo "Docker v$API_VERSION is not supported by your docker engine. Cannot proceed."
        exit 1
    fi
else
    echo "LOCAL_API_VERSION_NUMB or API_VERSION_NUMB are not set correctly. Cannot check if the API version is supported."
    sleep 10
fi

# Add important folders
mkdir -p /mnt/docker-aio-config/data/
mkdir -p /mnt/docker-aio-config/session/
mkdir -p /mnt/docker-aio-config/caddy/
mkdir -p /mnt/docker-aio-config/certs/ 

# Adjust permissions for all instances
chmod 770 -R /mnt/docker-aio-config
chmod 777 /mnt/docker-aio-config
chown www-data:www-data -R /mnt/docker-aio-config/data/
chown www-data:www-data -R /mnt/docker-aio-config/session/
chown root:root -R /mnt/docker-aio-config/caddy/
chown root:root -R /mnt/docker-aio-config/certs/

# Adjust certs
GENERATED_CERTS="/mnt/docker-aio-config/certs"
TMP_CERTS="/etc/apache2/certs"
mkdir -p "$GENERATED_CERTS"
cd "$GENERATED_CERTS"
if ! [ -f ./ssl.crt ] && ! [ -f ./ssl.key ]; then
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=DE/ST=BE/L=Local/O=Dev/CN=nextcloud.local" -keyout ./ssl.key -out ./ssl.crt
fi
if [ -f ./ssl.crt ] && [ -f ./ssl.key ]; then
    cd "$TMP_CERTS"
    rm ./ssl.crt
    rm ./ssl.key
    cp "$GENERATED_CERTS/ssl.crt" ./
    cp "$GENERATED_CERTS/ssl.key" ./
fi

print_green "Initial startup of Nextcloud All In One complete!
You should be able to open the Nextcloud AIO Interface now on port 8080 of this server!
E.g. https://internal.ip.of.this.server:8080

If your server has port 80 and 8443 open and you point a domain to your server, you can get a valid certificate automatially by opening the Nextcloud AIO Interface via:
https://your-domain-that-points-to-this-server.tld:8443"

exec "$@"
