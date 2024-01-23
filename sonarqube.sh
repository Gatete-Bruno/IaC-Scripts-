#!/bin/bash

# Update and install OpenJDK 11
sudo apt update -y
sudo apt-get install openjdk-11-jdk -y

# Install and configure PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install postgresql postgresql-contrib -y
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo passwd postgres
sudo su - postgres -c "createuser sonar"
sudo su - postgres -c "psql -c \"ALTER USER sonar WITH ENCRYPTED password 'my_strong_password';\""
sudo su - postgres -c "psql -c \"CREATE DATABASE sonarqube OWNER sonar;\""
sudo su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;\""
sudo su - postgres -c "psql -c \"\q\""
exit

# Download and install SonarQube
sudo apt-get install zip -y
SONARQUBE_VERSION="9.6.1.59531"
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
sudo unzip sonarqube-${SONARQUBE_VERSION}.zip
sudo mv sonarqube-${SONARQUBE_VERSION} /opt/sonarqube

# Add SonarQube user and group
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R

# Configure SonarQube
sudo nano /opt/sonarqube/conf/sonar.properties
# Add the following lines:
# sonar.jdbc.username=sonar
# sonar.jdbc.password=my_strong_password
# sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
# Save and exit

sudo nano /opt/sonarqube/bin/linux-x86-64/sonar.sh
# Uncomment the line: RUN_AS_USER=sonar
# Save and exit

# Setup Systemd service
sudo nano /etc/systemd/system/sonar.service
# Add the following lines:
# [Unit]
# Description=SonarQube service
# After=syslog.target network.target
# [Service]
# Type=forking
# ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
# ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
# User=sonar
# Group=sonar
# Restart=always
# LimitNOFILE=65536
# LimitNPROC=4096
# [Install]
# WantedBy=multi-user.target
# Save and exit

# Enable and start SonarQube service
sudo systemctl enable sonar
sudo systemctl start sonar

# Modify Kernel System Limits
sudo nano /etc/sysctl.conf
# Add the following lines:
# vm.max_map_count=262144
# fs.file-max=65536
# Save and exit

sudo sysctl -p

# Reboot the system
sudo reboot
