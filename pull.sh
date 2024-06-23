# pull changes from git continuoulsy using bash script
#!/bin/bash

while true
do
    git pull origin main
    sleep 1
done