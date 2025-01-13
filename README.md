# linux-web-server-boilerplate
A boilerplate for setting up a Linux web server with essential packages, user management, directory structure and logging.

# Overview
This repository contains a series of tasks and corresponding commands to set up and manage a Linux server for we hosting, database management, and monitoring. The tasks include user and directory management and logging to ensure a secure and efficient server environment.

# Tasks and Commands
## 1. Package Installation and Management
### Task:
Install essential packages for:
* Web serving (e.g., Nginx)
* Database management (e.g., MySQL)
* Monitoring (e.g., htop)
### Commands:
```bash
sudo apt-get update
sudo apt install nginx
sudo apt install mysql-server
sudo apt install htop
```
### Purpose: 
Ensures the server has the necessary tools to run web applications, manage data, and monitor performance.

---

## 2. User and Admin Creation
### Task:
* Create an admin user with sudo privileges.
* Create a standard user for running services.
* Enforce password policies.

### Commands:
```bash
# Create admin user
sudo useradd -g admin -d /home/admin admin

# Create standard user bob
sudo useradd -m -d /home/bob bob

# Set password policy for bob
sudo chage bob -M 5 -W 3 -I 6

# Verify user creation
grep bob /etc/passwd
```
### Purpose:
Improves security by sepaating user roles and enforcing password policies.

---

## 3. Folder and FIle Structure Creation
### Task:
Set up a structured directory system under /srv to organize web content, database backups, and logs.
### Commands: 
```bash
sudo mkdir -p /srv/webapp/backups
sudo mkdir /srv/webapp/logs
cd srv/webapp
sudo chown admin backups
sudo chown admin logs
ll (to verify)

sudo apt install acl
# Giving rwx permision to bob for logs folder
sudo setfacl -m u:bob:rwx /srv/webapp/logs
# Removing wx permissions of bob for backups folder
sudo setfacl -m u:bob:r /srv/webapp/backups
# Giving rwx permissions to admin user for backups and logs folders
sudo setfacl -m u:admin:rwx /srv/webapp/{backups,logs}
```
## Purpose:
Organized directories simplify maintenance and ensure access control.

## 4 Logging and Working with Files
### Task:
* Archive and compress old log files.
* Extract and review logs.
* Search logs for specific errors.
### Commands:
```bash
tar -cf log_test.tar log_test.txt 
tar -cf log_test2.tar log_test2.txt 
tar -cf log_test3.tar log_test3.txt 
tar -cf log_test4.tar log_test4.txt 
tar -cf log_test5.tar log_test5.txt
tar -cf log_test6.tar log_test6.txt 
tar -cf log_test7.tar log_test7.txt

# Compress log files
gzip log_test.tar log_test2.tar log_test3.tar log_test4.tar log_test5.tar log_test6.tar log_test7.tar

# Extract and review logs
zcat log_test.tar.gz

# View the first line containing "INFO" from the log file log_test.txt
less log_test.txt | grep "INFO" | head -n 1
# Decompress and view lines containing "ERROR" 
zcat log_test.tar.gz | grep "ERROR"
# View the first line containing "Scan complete"
less log_test2.txt | grep "Scan complete" | head -n 1
```
### Purpose:
Efficient log management prevents disk space issues and aids in troubleshooting.

---
## 5. Network management
### Task:
* Set up a firewall to allow traffic only on ports 80 (HTTP) and 443 (HTTPS).
### Commands:
```bash
# Firewall configuration
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -L INPUT -v -n --line-numbers
```
### Purpose
Secures the server by allowing only necessary traffic.

---
## 6. Process Isolation (Namespaces)
### Task:
* Use Linux Namespaces to isolate Nginx processes.
### Commands:
```bash
sudo systemctl stop nginx
# Launch a new shell (bash) inside the isolated namespaces
sudo unshare --pid --net --mount --fork --mount-proc bash
# Start nginx in the new namespace shell
/usr/sbin/nginx
# Verify if nginx is running
ps aux | grep nginx
# To re-enter the same namespace shell
sudo nsenter --target <PID> --pid --net
```
### Purpose
Prevents any single service from consuming all server resources.

## 7. Service Enabling (Systemd)
### Task:
* Create a systemd service to automatically start the web server.
### Commands:
```bash
# Create systemd service
sudo vim /etc/systemd/system/webserver.service
# Service file content:
[Unit]
Description=Web Server

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=graphical.target

# Reload and start service
sudo systemctl daemon-reload
sudo systemctl start webserver.service
sudo systemctl enable webserver.service
```
### Purpose
Automates service management.

---
## How to Use 
1. Clone the repository:
```bash
git clone <repository-url>
```
2. Navigate to the directory and follow the instructions for each task.
3. Ensure you have sudo privileges to execute the commands.
4. Modify configurations as needed for your environment.

