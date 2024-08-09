#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0" .sh)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE() {
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

echo "Updating system packages..." | tee -a $LOGFILE
sudo apt update >> $LOGFILE 2>&1
VALIDATE $? "System update"
sudo apt upgrade -y >> $LOGFILE 2>&1
VALIDATE $? "System upgrade"

echo "Installing OpenJDK 17..." | tee -a $LOGFILE
sudo apt install openjdk-17-jdk -y >> $LOGFILE 2>&1
VALIDATE $? "OpenJDK 17 installation"

echo "Downloading SonarQube..." | tee -a $LOGFILE
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.2.77730.zip -P /opt >> $LOGFILE 2>&1
VALIDATE $? "SonarQube download"

echo "Creating sonar user..." | tee -a $LOGFILE
if id "sonar" &>/dev/null; then
    echo -e "User 'sonar' already exists...$G SUCCESS $N" | tee -a $LOGFILE
else
    sudo useradd sonar >> $LOGFILE 2>&1
    VALIDATE $? "Sonar user creation"
fi

echo "Installing unzip..." | tee -a $LOGFILE
sudo apt install unzip -y >> $LOGFILE 2>&1
VALIDATE $? "Unzip installation"

echo "Unzipping SonarQube..." | tee -a $LOGFILE
if [ -d /opt/sonar ]; then
    echo -e "/opt/sonar already exists, skipping unzip...$G SUCCESS $N" | tee -a $LOGFILE
else
    sudo unzip /opt/sonarqube-9.9.2.77730.zip -d /opt >> $LOGFILE 2>&1
    VALIDATE $? "SonarQube unzip"
    sudo mv /opt/sonarqube-9.9.2.77730 /opt/sonar >> $LOGFILE 2>&1
    VALIDATE $? "Move SonarQube to /opt/sonar"
fi

echo "Setting permissions for SonarQube..." | tee -a $LOGFILE
sudo chown -R sonar:sonar /opt/sonar >> $LOGFILE 2>&1
VALIDATE $? "Setting permissions"

echo "Configuring sudoers for sonar user..." | tee -a $LOGFILE
if sudo grep -q "^sonar.*NOPASSWD:ALL" /etc/sudoers; then
    echo -e "Sonar user already in sudoers file...$G SUCCESS $N" | tee -a $LOGFILE
else
    echo "sonar   ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers >> $LOGFILE 2>&1
    VALIDATE $? "Sudoers configuration"
fi

echo "Creating systemd service file for SonarQube..." | tee -a $LOGFILE
SONAR_SERVICE_FILE="/etc/systemd/system/sonar.service"
if [ -f $SONAR_SERVICE_FILE ]; then
    echo -e "Sonar service file already exists...$G SUCCESS $N" | tee -a $LOGFILE
else
    echo "[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
User=sonar
ExecStart=/opt/sonar/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonar/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target" | sudo tee $SONAR_SERVICE_FILE >> $LOGFILE 2>&1
    VALIDATE $? "Systemd service file creation"
fi

echo "Starting and enabling SonarQube service..." | tee -a $LOGFILE
sudo systemctl daemon-reload >> $LOGFILE 2>&1
VALIDATE $? "Daemon reload"
sudo systemctl enable sonar >> $LOGFILE 2>&1
VALIDATE $? "Sonar service enable"
sudo systemctl start sonar >> $LOGFILE 2>&1
VALIDATE $? "Sonar service start"

echo -e "SonarQube setup...$G COMPLETED $N" | tee -a $LOGFILE


# admin admin

# netstat -lntp
# journalctl -u sonar
# ss -tunlp