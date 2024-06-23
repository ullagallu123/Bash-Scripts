#!/bin/bash
aws ec2 run-instances \
    --image-id ami-08a0d1e16fc3f61ea \
    --instance-type t3a.medium \
    --key-name siva \
    --user-data file:///home/cloudshell-user/bash-scripts/docker-installation.sh \
    --count 1