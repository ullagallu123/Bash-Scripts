#!/bin/bash
aws ec2 run-instances \
    --image-id ami-08a0d1e16fc3f61ea \
    --instance-type t3.micro \
    --key-name siva \
    --user-data file:///home/cloudshell-user/bash-scripts/docker-installation.sh \
    --placement "AvailabilityZone=us-east-1a" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=docker}]' \
    --count 1