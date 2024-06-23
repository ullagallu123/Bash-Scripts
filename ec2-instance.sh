# spinup ec2 instance using aws cli commands
#!/bin/bash
aws ec2 run-instances \
    --image-id ami-04b70fa74e45c3917 \
    --count 1 \
    --instance-type t3.micro \
    --key-name siva \
    --security-group-ids sg-017478371c019d04d \
    --subnet-id subnet-0e2ae409c6aa2fd85 \
    --user-data file:///home/cloudshell-user/nginx.sh

aws ec2 run-instances \
    --image-id ami-04b70fa74e45c3917 \
    --count 1 \
    --instance-type t3.micro \
    --key-name siva \
    --security-group-ids sg-017478371c019d04d \
    --subnet-id subnet-0c1a0c1fefa2a3a51 \
    --user-data file:///home/cloudshell-user/nginx.sh