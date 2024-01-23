#!/bin/bash

# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https software-properties-common

# Add the GPG Key for Grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Add the repository for Grafana stable releases
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update package list again
sudo apt-get update

# Install Grafana
sudo apt-get -y install grafana

# Enable and start Grafana service
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Check the status of Grafana service
sudo systemctl status grafana-server
