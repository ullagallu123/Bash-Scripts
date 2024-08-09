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

echo "Changing to /tmp directory..." | tee -a $LOGFILE
cd /tmp >> $LOGFILE 2>&1
VALIDATE $? "Changing to /tmp directory"

echo "Downloading Node Exporter..." | tee -a $LOGFILE
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz >> $LOGFILE 2>&1
VALIDATE $? "Downloading Node Exporter"

echo "Extracting Node Exporter..." | tee -a $LOGFILE
tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz >> $LOGFILE 2>&1
VALIDATE $? "Extracting Node Exporter"

echo "Moving Node Exporter binary to /usr/local/bin..." | tee -a $LOGFILE
mv -f node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/ >> $LOGFILE 2>&1
VALIDATE $? "Moving Node Exporter binary to /usr/local/bin"

if ! id "node_exporter" &>/dev/null; then
    echo "Creating node_exporter user..." | tee -a $LOGFILE
    useradd -rs /bin/false node_exporter >> $LOGFILE 2>&1
    VALIDATE $? "Creating node_exporter user"
else
    echo "User node_exporter already exists." | tee -a $LOGFILE
fi

echo "Creating Node Exporter service file..." | tee -a $LOGFILE
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
VALIDATE $? "Creating Node Exporter service file"

echo "Reloading systemd daemon..." | tee -a $LOGFILE
systemctl daemon-reload >> $LOGFILE 2>&1
VALIDATE $? "Reloading systemd daemon"

echo "Starting Node Exporter service..." | tee -a $LOGFILE
systemctl start node_exporter >> $LOGFILE 2>&1
VALIDATE $? "Starting Node Exporter service"

echo "Enabling Node Exporter service..." | tee -a $LOGFILE
systemctl enable node_exporter >> $LOGFILE 2>&1
VALIDATE $? "Enabling Node Exporter service"

echo "Restarting Prometheus service..." | tee -a $LOGFILE
systemctl restart prometheus >> $LOGFILE 2>&1
VALIDATE $? "Restarting Prometheus service"

echo "Script completed successfully." | tee -a $LOGFILE
