#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N" | tee -a $LOGFILE
        exit 1
    else
        echo -e "$2...$G SUCCESS $N" | tee -a $LOGFILE
    fi
}

if [ $USERID -ne 0 ]; then
    echo "Please run this script with root access." | tee -a $LOGFILE
    exit 1
else
    echo "You are super user." | tee -a $LOGFILE
fi

# Add Grafana GPG key
if ! apt-key list | grep -q 'Grafana'; then
    echo "Adding Grafana GPG key..." | tee -a $LOGFILE
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    VALIDATE $? "Adding Grafana GPG key"
else
    echo "Grafana GPG key already added." | tee -a $LOGFILE
fi

# Add Grafana repository
if ! grep -q 'packages.grafana.com' /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    echo "Adding Grafana repository..." | tee -a $LOGFILE
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    VALIDATE $? "Adding Grafana repository"
else
    echo "Grafana repository already added." | tee -a $LOGFILE
fi

# Update package list
echo "Updating package list..." | tee -a $LOGFILE
sudo apt update
VALIDATE $? "Updating package list"

# Install Grafana
if ! dpkg -l | grep -q grafana; then
    echo "Installing Grafana..." | tee -a $LOGFILE
    sudo apt install -y grafana
    VALIDATE $? "Installing Grafana"
else
    echo "Grafana already installed." | tee -a $LOGFILE
fi

# Start Grafana service
echo "Starting Grafana service..." | tee -a $LOGFILE
sudo systemctl start grafana-server
VALIDATE $? "Starting Grafana service"

# Enable Grafana service to start on boot
echo "Enabling Grafana service to start on boot..." | tee -a $LOGFILE
sudo systemctl enable grafana-server
VALIDATE $? "Enabling Grafana service to start on boot"

# Check Grafana service status
echo "Checking Grafana service status..." | tee -a $LOGFILE
sudo systemctl status grafana-server
VALIDATE $? "Checking Grafana service status"

echo "Script completed successfully." | tee -a $LOGFILE
