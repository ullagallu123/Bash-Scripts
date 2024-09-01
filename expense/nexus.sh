#!/bin/bash

# Define log file
LOG_FILE="/tmp/nexus_setup_$(date +'%Y%m%d_%H%M%S').log"

# Logging function
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check for sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    log "This script must be run as root" >&2
    exit 1
fi

log "Starting Nexus setup..."

# Update package list
log "Updating package list..."
apt-get update -y | tee -a "$LOG_FILE"

# Install OpenJDK 8 if not already installed
if ! dpkg -l | grep -q openjdk-17-jdk ; then
    log "Installing OpenJDK 8..."
    apt-get install openjdk-17-jdk  -y | tee -a "$LOG_FILE"
else
    log "OpenJDK 17 is already installed."
fi

# Download and extract Nexus if not already present
if [ ! -d /opt/nexus ]; then
    log "Downloading and extracting Nexus..."
    cd /opt
    wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz | tee -a "$LOG_FILE"
    tar -zxvf latest-unix.tar.gz | tee -a "$LOG_FILE"
    mv /opt/nexus-* /opt/nexus | tee -a "$LOG_FILE"
else
    log "Nexus is already downloaded and extracted."
fi

# Create nexus user if it doesn't exist
if ! id -u nexus > /dev/null 2>&1; then
    log "Creating nexus user..."
    useradd nexus | tee -a "$LOG_FILE"
else
    log "User 'nexus' already exists."
fi

# Configure sudoers for nexus user if not already configured
if ! sudo grep -q "nexus ALL=(ALL) NOPASSWD: ALL" /etc/sudoers; then
    log "Configuring sudoers for nexus user..."
    echo "nexus ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
else
    log "Sudoers configuration for nexus user already exists."
fi

# Set ownership of Nexus directories
log "Setting ownership of Nexus directories..."
chown -R nexus:nexus /opt/nexus | tee -a "$LOG_FILE"
chown -R nexus:nexus /opt/sonatype-work | tee -a "$LOG_FILE"

# Configure Nexus to run as nexus user
NEXUS_RC_FILE="/opt/nexus/bin/nexus.rc"
if ! grep -q "run_as_user=\"nexus\"" $NEXUS_RC_FILE; then
    log "Configuring Nexus to run as nexus user..."
    echo 'run_as_user="nexus"' > $NEXUS_RC_FILE
else
    log "Nexus is already configured to run as nexus user."
fi

# Create systemd service file for Nexus if not already present
NEXUS_SERVICE_FILE="/etc/systemd/system/nexus.service"
if [ ! -f $NEXUS_SERVICE_FILE ]; then
    log "Creating systemd service file for Nexus..."
    cat <<EOF > $NEXUS_SERVICE_FILE
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF
else
    log "Systemd service file for Nexus already exists."
fi

# Start and enable Nexus service
log "Starting and enabling Nexus service..."
systemctl start nexus | tee -a "$LOG_FILE"
systemctl enable nexus | tee -a "$LOG_FILE"

# Check Nexus service status
log "Checking Nexus service status..."
systemctl status nexus | tee -a "$LOG_FILE"

# Allow traffic on port 8081
log "Allowing traffic on port 8081..."
ufw allow 8081/tcp | tee -a "$LOG_FILE"

log "Nexus setup completed."

# you can find logs of nexus on this location tail -f /opt/sonatype-work/nexus3/log/nexus.log
# netstat -lntp
# journalctl -u nexus
# ss -tunlp
# ip:8081
# username: admin
