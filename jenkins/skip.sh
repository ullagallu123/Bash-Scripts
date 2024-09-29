#!/bin/bash

# Variables
JENKINS_HOME="/var/jenkins_home"
CONFIG_FILE="$JENKINS_HOME/config.xml"
RUN_SETUP_WIZARD_FILE="$JENKINS_HOME/jenkins.install.runSetupWizard"
LAST_EXEC_VERSION_FILE="$JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion"

# Function to check if a file exists and create it if not
create_file_if_not_exists() {
    local file_path=$1
    local content=$2

    if [ ! -f "$file_path" ]; then
        echo "$content" > "$file_path"
        echo "Created $file_path"
    else
        echo "$file_path already exists, skipping creation."
    fi
}

# Ensure Jenkins home directory exists
if [ ! -d "$JENKINS_HOME" ]; then
    echo "Jenkins home directory does not exist. Please check your installation."
    exit 1
fi

# Modify config.xml to set install state to RUNNING if not already set
if grep -q "<installStateName>NEW</installStateName>" "$CONFIG_FILE"; then
    sed -i 's/<installStateName>NEW<\/installStateName>/<installStateName>RUNNING<\/installStateName>/' "$CONFIG_FILE"
    echo "Updated install state to RUNNING in $CONFIG_FILE"
else
    echo "Install state is already set to RUNNING."
fi

# Create or update runSetupWizard file
create_file_if_not_exists "$RUN_SETUP_WIZARD_FILE" "false"

# Create or update lastExecVersion file
create_file_if_not_exists "$LAST_EXEC_VERSION_FILE" "2.0"

# Restart Jenkins service (adjust command as necessary for your system)
echo "Restarting Jenkins..."
systemctl restart jenkins

echo "Jenkins setup completed successfully."