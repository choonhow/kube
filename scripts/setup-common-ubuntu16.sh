#!/bin/bash

echo "###################################"
echo "## Adding dns server with google dns server ..."
echo "###################################"
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null

echo "###################################"
echo "## Updating Repo ..."
echo "###################################"
sudo apt-get update -y 

echo "###################################"
echo "## Installing python..."
echo "###################################"
sudo apt-get install -y python-minimal python-apt

echo "###################################"
echo "## Installing Repo ..."
echo "###################################"
sudo apt-get install -y software-properties-common
sudo apt-add-repository ppa:ansible/ansible

echo "###################################"
echo "## Updating Repo ..."
echo "###################################"
sudo apt-get update -y 

echo "###################################"
echo "## Installing Ansible..."
echo "###################################"
sudo apt-get install -y ansible

