#!/bin/bash
sudo yum update -y
sudo yum install wget
sudo yum search docker -y
sudo yum install docker -y
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service

cat << EOF > home/ec2-user/Dockerfile
FROM ghcr.io/runatlantis/atlantis:latest

RUN mkdir /home/atlantis/.aws

RUN touch /home/atlantis/.aws/credentials

RUN chown atlantis.atlantis /home/atlantis/ -R
EOF
