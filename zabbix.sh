#!/bin/bash

# Step 1: Install Zabbix repository
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
apt update

# Step 2: Install Zabbix server, frontend, agent
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

# Step 3: Create initial database
echo "Make sure you have database server up and running."
echo "Run the following on your database host."
echo "mysql -uroot -p"
echo "password"
echo "mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;"
echo "mysql> create user zabbix@localhost identified by 'password';"
echo "mysql> grant all privileges on zabbix.* to zabbix@localhost;"
echo "mysql> set global log_bin_trust_function_creators = 1;"
echo "mysql> quit;"

# Step 4: Import initial schema and data
echo "On Zabbix server host import initial schema and data. You will be prompted to enter your newly created password."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

# Step 5: Disable log_bin_trust_function_creators option
echo "Disable log_bin_trust_function_creators option after importing database schema."
echo "mysql -uroot -p"
echo "password"
echo "mysql> set global log_bin_trust_function_creators = 0;"
echo "mysql> quit;"

# Step 6: Configure the database for Zabbix server
echo "Editing file /etc/zabbix/zabbix_server.conf"
echo "DBPassword=password" >> /etc/zabbix/zabbix_server.conf

# Step 7: Configure PHP for Zabbix frontend
echo "Editing file /etc/zabbix/nginx.conf"
sed -i 's/# listen 8080;/listen 8080;/' /etc/zabbix/nginx.conf
sed -i 's/# server_name example.com;/server_name example.com;/' /etc/zabbix/nginx.conf

# Step 8: Start Zabbix server and agent processes
systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm

echo "Zabbix installation and configuration completed."
