#!/bin/bash
dnf install git -y
dnf install docker -y
systemctl start docker
usermod -aG docker ec2-user
systemctl stop docker
systemctl start docker
curl -SL https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

minikube start --network-plugin=cni --cni=calico