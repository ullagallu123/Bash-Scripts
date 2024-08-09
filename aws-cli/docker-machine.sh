#!/bin/bash
aws ec2 run-instances \
  --image-id ami-0ec0e125bb6c6e8ec \
  --instance-type t3a.medium \
  --key-name siva \
  --user-data file://docker-installation.sh \
  --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=one-time}" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=docker}]' \
  --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=20,VolumeType=gp2,DeleteOnTermination=true}'
