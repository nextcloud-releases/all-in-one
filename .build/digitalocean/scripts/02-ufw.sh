#!/bin/sh

ufw limit ssh
ufw allow http
ufw allow https
ufw allow 443/udp
ufw allow 3478/tcp
ufw allow 3478/udp
ufw allow 8080/tcp
ufw allow 8443/tcp

ufw --force enable
