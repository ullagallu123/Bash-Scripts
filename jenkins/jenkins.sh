#!/bin/bash

# Install Java if not already installed
if ! java -version &>/dev/null; then
    echo "Installing Java 17 Amazon Corretto..."
    sudo yum install -y java-17-amazon-corretto-devel
else
    echo "Java is already installed."
fi

# Set up Jenkins repository if not already set up
REPO_FILE="/etc/yum.repos.d/jenkins.repo"
if [ ! -f "$REPO_FILE" ]; then
    echo "Setting up Jenkins repository..."
    sudo wget -O "$REPO_FILE" https://pkg.jenkins.io/redhat-stable/jenkins.repo
else
    echo "Jenkins repository is already set up."
fi

# Import the Jenkins GPG key if not already imported
if ! rpm -q gpg-pubkey-$(curl -s https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key | gpg --with-fingerprint | grep -oP '^[^ ]+') &>/dev/null; then
    echo "Importing Jenkins GPG key..."
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
else
    echo "Jenkins GPG key is already imported."
fi

# Install Jenkins if not already installed
if ! rpm -q jenkins &>/dev/null; then
    echo "Installing Jenkins..."
    sudo yum install -y jenkins
else
    echo "Jenkins is already installed."
fi

# Reload systemd daemon to recognize new service files (if needed)
sudo systemctl daemon-reload

# Enable and start Jenkins service if not already enabled and started
if ! systemctl is-enabled jenkins &>/dev/null; then
    echo "Enabling Jenkins service..."
    sudo systemctl enable jenkins
fi

if ! systemctl is-active jenkins &>/dev/null; then
    echo "Starting Jenkins service..."
    sudo systemctl start jenkins
else
    echo "Jenkins service is already running."
fi

echo "Jenkins setup completed successfully."