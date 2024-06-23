#!/bin/bash
dnf install docker -y
systemctl start docker
usermod -aG docker ec2-user
systemctl stop docker
systemctl start docker
