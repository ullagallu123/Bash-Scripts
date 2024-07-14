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

dnf install nginx -y >> $LOGFILE 2>&1
VALIDATE $? "Installing Nginx"

systemctl enable nginx >> $LOGFILE 2>&1
VALIDATE $? "Enabling Nginx"

systemctl start nginx >> $LOGFILE 2>&1
VALIDATE $? "Starting Nginx"

# Check if Nginx is running and serving default content
curl -I http://localhost | grep "200 OK" >> $LOGFILE 2>&1
VALIDATE $? "Checking Nginx default content"

rm -rf /usr/share/nginx/html/* >> $LOGFILE 2>&1
VALIDATE $? "Removing default Nginx content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip >> $LOGFILE 2>&1
VALIDATE $? "Downloading frontend content"



cd /usr/share/nginx/html >> $LOGFILE 2>&1
unzip /tmp/frontend.zip >> $LOGFILE 2>&1
VALIDATE $? "Unzipping frontend content"

# Check if Nginx is running and serving frontend content
curl -I http://localhost | grep "200 OK" >> $LOGFILE 2>&1
VALIDATE $? "Checking Nginx frontend content"

cat <<EOF > /etc/nginx/default.d/expense.conf
proxy_http_version 1.1;

location /api/ { proxy_pass http://expense.backend.test.ullagallu.cloud:8080/; }

location /health {
  stub_status on;
  access_log off;
}
EOF
VALIDATE $? "Creating Nginx reverse proxy configuration"

systemctl restart nginx >> $LOGFILE 2>&1
VALIDATE $? "Restarting Nginx"

echo -e "$G All tasks completed successfully! $N"



https://github.com/srkugl/expense-project.git
code is there in frontend/