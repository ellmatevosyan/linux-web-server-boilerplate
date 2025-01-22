#!/bin/bash

echo "Update package lists"
sudo apt-get update

echo "install required packages"
sudo apt install -y nginx mysql-server htop acl

echo "Create admin user"
sudo useradd -g admin -d /home/admin admin

echo "Create standard user bob with password policy"
sudo useradd -m -d /home/bob bob
sudo chage bob -M 5 -W 3 -I 6

echo "Verify user creation"
cat /etc/passwd | grep 'bob'

echo "Create directories"
sudo mkdir -p /srv/webapp/backups
sudo mkdir -p /srv/webapp/logs

echo "Change ownership"
sudo chown admin /srv/webapp/backups
sudo chown admin /srv/webapp/logs

echo "Grant permissions using acl"
sudo setfacl -m u:bob:rwx /srv/webapp/logs
sudo setfacl -m u:bob:r /srv/webapp/backups
sudo setfacl -m u:admin:rwx /srv/webapp/{backups,logs}

echo "Create log files and compress them"
for i in {1..7}; do 
    echo "Sample log content for log_test${i}.txt" > log_test${i}.txt
    tar -cf log_test${i}.tar log_test${i}.txt
done

echo "Compress log files"
gzip log_test*.tar

echo "Extract and review logs"
zcat log_test1.tar.gz

echo "View specific log entries"
less log_test1.txt | grep "INFO" | head -n 1
zcat log_test1.tar.gz | grep "ERROR"
less log_test2.txt | grep "Scan complete" | head -n 1

echo "Configure firewall rules"
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -L INPUT -v -n --line-numbers

echo "Stop nginx if running"
sudo systemctl stop nginx

echo "Start nginx in an isolated namespace"
sudo unshare --pid --net --mount --fork --mount-proc bash -c "/usr/sbin/nginx & ps aux | grep nginx"

# Create systemd service for nginx
sudo bash -c 'cat > /etc/systemd/system/webserver.service << EOF
[Unit]
Description=Web Server

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g "daemon on; master_process on;"
ExecStart=/usr/sbin/nginx -g "daemon on; master_process on;"
ExecReload=/usr/sbin/nginx -g "daemon on; master_process on;" -s reload
ExecStop=/bin/kill -s TERM \$MAINPID
PrivateTmp=true

[Install]
WantedBy=graphical.target
EOF'

echo "Reload systemd and start service"
sudo systemctl daemon-reload
sudo systemctl start webserver.service
sudo systemctl enable webserver.service

echo "Script execution completed successfully."