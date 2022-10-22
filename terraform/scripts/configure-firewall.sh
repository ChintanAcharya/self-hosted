#!/bin/sh

sudo ufw default allow outgoing
sudo ufw default deny incoming

# SSH
sudo ufw allow ssh

# Wireguard
sudo ufw allow 51820/udp

# Minecraft Proxy
sudo ufw allow 19132/udp

sudo systemctl enable ufw
