#!/bin/bash

# Update packages
sudo yum update -y

# Install basic tools
sudo yum install -y git vim htop

# Optional: Welcome message
echo "Bastion host is ready." | sudo tee /etc/motd
