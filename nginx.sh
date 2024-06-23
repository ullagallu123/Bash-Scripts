#!/bin/bash

apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
rm /var/www/html/index.nginx-debian.html
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "<h1>The server IP address is $SERVER_IP</h1>" | sudo tee /var/www/html/index.html > /dev/null
echo "Nginx has been installed and configured. You can visit the server's IP address to see the message."