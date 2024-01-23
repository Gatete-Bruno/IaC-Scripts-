#!/bin/bash

# Step a: Install required packages
sudo apt-get install -y wget apt-transport-https gnupg lsb-release

# Step b: Add the Trivy repository key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

# Step c: Add the Trivy repository to sources list
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

# Step d: Update the package list
sudo apt-get update

# Step e: Install Trivy
sudo apt-get install -y trivy
