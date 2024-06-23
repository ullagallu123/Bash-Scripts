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

echo "Updating package list..."
apt update -y
VALIDATE $? "apt update"

if ! id "prometheus" &>/dev/null; then
    echo "Creating prometheus user..."
    useradd --no-create-home --shell /bin/false prometheus
    VALIDATE $? "Creating prometheus user"
else
    echo "User prometheus already exists." | tee -a $LOGFILE
fi

echo "Creating necessary directories..."
mkdir -p /etc/prometheus /var/lib/prometheus
VALIDATE $? "Creating directories"

echo "Setting ownership for /var/lib/prometheus..."
chown prometheus:prometheus /var/lib/prometheus
VALIDATE $? "Setting ownership for /var/lib/prometheus"

echo "Downloading Prometheus..."
cd /tmp/
wget -q https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz
VALIDATE $? "Downloading Prometheus"

echo "Extracting Prometheus..."
tar -xzf prometheus-2.46.0.linux-amd64.tar.gz
VALIDATE $? "Extracting Prometheus"

cd prometheus-2.46.0.linux-amd64
echo "Moving files to /etc/prometheus..."
mv -f consoles /etc/prometheus
mv -f console_libraries /etc/prometheus
mv -f prometheus.yml /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus
VALIDATE $? "Moving files to /etc/prometheus"

echo "Moving Prometheus binary to /usr/local/bin..."
mv -f prometheus /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
VALIDATE $? "Moving Prometheus binary to /usr/local/bin"

echo "Creating Prometheus service file..."
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
VALIDATE $? "Creating Prometheus service file"

echo "Reloading systemd daemon..."
systemctl daemon-reload
VALIDATE $? "Reloading systemd daemon"

echo "Starting Prometheus service..."
systemctl start prometheus
VALIDATE $? "Starting Prometheus service"

echo "Enabling Prometheus service..."
systemctl enable prometheus
VALIDATE $? "Enabling Prometheus service"

echo "Checking Prometheus service status..."
systemctl status prometheus
VALIDATE $? "Checking Prometheus service status"

echo "Script completed successfully." | tee -a $LOGFILE

# 9090