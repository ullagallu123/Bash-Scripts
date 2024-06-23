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

# Disable the current Node.js module if enabled
dnf module disable nodejs:18 -y &>>"$LOG_FILE"
VALIDATE $? "Disabling current Node.js module"

# Enable Node.js 20 module
dnf module enable nodejs:20 -y &>>"$LOG_FILE"
VALIDATE $? "Enabling Node.js 20"

# Install Node.js 20
dnf install nodejs -y &>>"$LOG_FILE"
VALIDATE $? "Installing Node.js 20"

# Check the installed Node.js version
node -v &>>"$LOG_FILE"
VALIDATE $? "Checking the version of Node.js"

# Install MySQL client
dnf install mysql -y &>>"$LOG_FILE"
VALIDATE $? "Installing MySQL client"

# Check if the user 'wages' already exists
if id "wages" &>/dev/null; then
    echo -e "${Y}User 'wages' already exists, skipping creation${N}" | tee -a "$LOG_FILE"
else
    useradd wages &>>"$LOG_FILE"
    VALIDATE $? "Creating user 'wages'"
fi

# Function to check if a directory exists and create it if not
check_directory() {
    if [ -d "$1" ]; then
        echo -e "${Y}Folder '$1' already exists, skipping creation${N}" | tee -a "$LOG_FILE"
    else
        mkdir -p "$1" &>>"$LOG_FILE"
        VALIDATE $? "Creating Folder '$1'"
    fi
}

check_directory "/app"

# Check if the repository is already cloned
if [ -d /app/.git ]; then
    echo -e "${Y}Repository already cloned, skipping download${N}" | tee -a "$LOG_FILE"
else
    git clone https://github.com/ullagallu123/exp-backend.git /app &>>"$LOG_FILE"
    VALIDATE $? "Downloading code into the app directory"
fi

# Change to the app directory
cd /app &>>"$LOG_FILE"
VALIDATE $? "Changing to Folder '/app'"

# Install npm dependencies
npm install &>>"$LOG_FILE"
VALIDATE $? "Building the application"

# Copy the backend service file
cp /home/ec2-user/devops-code/bash-scripts/backend.service /etc/systemd/system/ &>>"$LOG_FILE"
VALIDATE $? "Adding service file for backend"

# Configure the schema
mysql -h db.ullagallubuffellomilk.store -uroot -psiva < /app/schema/backend.sql &>>"$LOG_FILE"
VALIDATE $? "Configuring the schema"

# Reload the systemd manager configuration
systemctl daemon-reload &>>"$LOG_FILE"
VALIDATE $? "Reloading the service files in the system"

# Start the backend service
systemctl start backend &>>"$LOG_FILE"
VALIDATE $? "Starting the backend service"

# Enable the backend service to start on boot
systemctl enable backend &>>"$LOG_FILE"
VALIDATE $? "Enabling backend service on boot"

echo "Script execution completed at: $(date +%F-%H-%M-%S)" | tee -a "$LOG_FILE"
