#!/bin/bash

# Install Docker and run a container on port 8080 with nginx
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
docker run -p 8080:80 nginx