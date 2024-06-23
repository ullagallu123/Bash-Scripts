# using aws cli command creating mysql db on aws cloud
#!/bin/bash
aws rds create-db-instance \
    --db-instance-identifier my-mysql-instance \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --allocated-storage 20 \
    --master-username expense \
    --master-user-password ExpenseApp1 \
    --db-name mydatabase \
    --vpc-security-group-ids sg-017478371c019d04d \
    --availability-zone us-east-1a \
    --backup-retention-period 0 \
    --no-multi-az \
    --storage-type gp3 \
    --publicly-accessible \
    --tags Key=Name,Value=MyDatabaseInstance