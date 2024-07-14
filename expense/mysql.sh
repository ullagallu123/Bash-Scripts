#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo "Please run this script with root access."
        exit 1
    fi
}

check_root

dnf update -y >> $LOGFILE 2>&1
VALIDATE $? "Updating Packages"

dnf install mysql-server -y >> $LOGFILE 2>&1
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld >> $LOGFILE 2>&1
VALIDATE $? "Enabling MySQL service"

systemctl start mysqld >> $LOGFILE 2>&1
VALIDATE $? "Starting MySQL service"

mysql_secure_installation --set-root-pass ExpenseApp@1 >> $LOGFILE 2>&1
VALIDATE $? "Securing MySQL installation"

echo -e "$G All tasks completed successfully! $N"
