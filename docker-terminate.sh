#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0"
  exit 1
fi

INSTANCE_ID=$1

aws ec2 terminate-instances --instance-ids $INSTANCE_ID

if [ $? -eq 0 ]; then
  echo "Instance $INSTANCE_ID has been terminated successfully."
else
  echo "Failed to terminate instance $INSTANCE_ID."
fi