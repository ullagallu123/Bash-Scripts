# This bash script was used to install Jenkins Server on Amazon Linux3....
#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename $0 .sh)
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

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1
else
    echo "You are super user."
fi

echo "Updating system packages..."
dnf update -y >> $LOGFILE 2>&1
VALIDATE $? "System update"

echo "Installing Java 17 Amazon Corretto..."
if ! rpm -q java-17-amazon-corretto-devel; then
    yum install -y java-17-amazon-corretto-devel >> $LOGFILE 2>&1
    VALIDATE $? "Java 17 Amazon Corretto installation"
else
    echo -e "Java 17 Amazon Corretto is already installed...$G SUCCESS $N"
fi

echo "Setting up Jenkins repository..."
if [ ! -f /etc/yum.repos.d/jenkins.repo ]; then
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo >> $LOGFILE 2>&1
    VALIDATE $? "Jenkins repository setup"
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key >> $LOGFILE 2>&1
    VALIDATE $? "Jenkins key import"
else
    echo -e "Jenkins repository is already set up...$G SUCCESS $N"
fi

echo "Installing Jenkins..."
if ! rpm -q jenkins; then
    yum install -y jenkins >> $LOGFILE 2>&1
    VALIDATE $? "Jenkins installation"
else
    echo -e "Jenkins is already installed...$G SUCCESS $N"
fi

echo "Configuring Jenkins service..."
systemctl daemon-reload >> $LOGFILE 2>&1
systemctl enable jenkins >> $LOGFILE 2>&1
VALIDATE $? "Jenkins service enabled"
systemctl start jenkins >> $LOGFILE 2>&1
VALIDATE $? "Jenkins service started"

echo -e "Jenkins setup...$G COMPLETED $N"
