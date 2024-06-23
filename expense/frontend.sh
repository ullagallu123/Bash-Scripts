#!/bin/bash

USERID=$(id -u) # It gives user id
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
LOG_FILE="/tmp/${TIMESTAMP}-${SCRIPT_NAME}.log"

# colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Script started executing at: $TIMESTAMP"
echo "Log file: $LOG_FILE"

# Check if the script is run as root
if [ $USERID -ne 0 ]; then
    echo -e "${R}Please run this script with sudo privileges${N}"
    exit 1
else
    echo -e "${G}Here we go to installation${N}"
fi

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2.......${R}Failed${N}" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$2.....${G}Success${N}" | tee -a "$LOG_FILE"
    fi
}

dnf install nginx -y &>>"$LOG_FILE"
VALIDATE $? "Installing Nginx"

# systemctl enable nginx &>>"$LOG_FILE"
# VALIDATE $? "Enabling Nginx on boot"

# systemctl start nginx &>>"$LOG_FILE"
# VALIDATE $? "Starting Nginx server"

rm -rf /usr/share/nginx/html/* &>>"$LOG_FILE"
VALIDATE $? "Removing default Nginx content"

# Check if repository is already cloned
if [ -d /usr/share/nginx/html/.git ]; then
    echo -e "${Y}Repository already cloned, skipping download${N}" | tee -a "$LOG_FILE"
else
    git clone https://github.com/ullagallu123/exp-frontend.git /usr/share/nginx/html &>>"$LOG_FILE"
    VALIDATE $? "Cloning the code to the Nginx default directory"
fi

cp /home/ec2-user/devops-code/bash-scripts/expense.conf /etc/nginx/default.d/ &>>"$LOG_FILE"
VALIDATE $? "Copying expense configuration to Nginx"

systemctl restart nginx &>>"$LOG_FILE"
VALIDATE $? "Restarting Nginx server"

echo "Script execution completed at: $(date +%F-%H-%M-%S)" | tee -a "$LOG_FILE"
