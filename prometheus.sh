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

echo "Updating package list..." | tee -a $LOGFILE
apt update -y >> $LOGFILE 2>&1
VALIDATE $? "apt update"

if ! id "prometheus" &>/dev/null; then
    echo "Creating prometheus user..." | tee -a $LOGFILE
    useradd --no-create-home --shell /bin/false prometheus >> $LOGFILE 2>&1
    VALIDATE $? "Creating prometheus user"
else
    echo "User prometheus already exists." | tee -a $LOGFILE
fi

echo "Creating necessary directories..." | tee -a $LOGFILE
mkdir -p /etc/prometheus /var/lib/prometheus >> $LOGFILE 2>&1
VALIDATE $? "Creating directories"

echo "Setting ownership for /var/lib/prometheus..." | tee -a $LOGFILE
chown prometheus:prometheus /var/lib/prometheus >> $LOGFILE 2>&1
VALIDATE $? "Setting ownership for /var/lib/prometheus"

echo "Downloading Prometheus..." | tee -a $LOGFILE
cd /tmp/ >> $LOGFILE 2>&1
wget -q https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz >> $LOGFILE 2>&1
VALIDATE $? "Downloading Prometheus"

echo "Extracting Prometheus..." | tee -a $LOGFILE
tar -xzf prometheus-2.46.0.linux-amd64.tar.gz >> $LOGFILE 2>&1
VALIDATE $? "Extracting Prometheus"

cd prometheus-2.46.0.linux-amd64 >> $LOGFILE 2>&1
echo "Moving files to /etc/prometheus..." | tee -a $LOGFILE
mv -f consoles /etc/prometheus >> $LOGFILE 2>&1
mv -f console_libraries /etc/prometheus >> $LOGFILE 2>&1
mv -f prometheus.yml /etc/prometheus >> $LOGFILE 2>&1
chown -R prometheus:prometheus /etc/prometheus >> $LOGFILE 2>&1
VALIDATE $? "Moving files to /etc/prometheus"

echo "Moving Prometheus binary to /usr/local/bin..." | tee -a $LOGFILE
mv -f prometheus /usr/local/bin/ >> $LOGFILE 2>&1
chown prometheus:prometheus /usr/local/bin/prometheus >> $LOGFILE 2>&1
VALIDATE $? "Moving Prometheus binary to /usr/local/bin"

echo "Creating Prometheus service file..." | tee -a $LOGFILE
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

echo "Reloading systemd daemon..." | tee -a $LOGFILE
systemctl daemon-reload >> $LOGFILE 2>&1
VALIDATE $? "Reloading systemd daemon"

echo "Starting Prometheus service..." | tee -a $LOGFILE
systemctl start prometheus >> $LOGFILE 2>&1
VALIDATE $? "Starting Prometheus service"

echo "Enabling Prometheus service..." | tee -a $LOGFILE
systemctl enable prometheus >> $LOGFILE 2>&1
VALIDATE $? "Enabling Prometheus service"

echo "Checking Prometheus service status..." | tee -a $LOGFILE
systemctl status prometheus >> $LOGFILE 2>&1
VALIDATE $? "Checking Prometheus service status"

echo "Script completed successfully." | tee -a $LOGFILE
