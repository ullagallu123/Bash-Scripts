#!/bin/bash
dnf install docker -y
systemctl start docker
usermod -aG docker ec2-user
systemctl stop docker
systemctl start docker
curl -SL https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose