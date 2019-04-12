#!/bin/bash

echo "update hosts file ..."
sudo mv hosts /etc/hosts

echo "change id_rsa permission ..."
sudo chmod 0600 /home/vagrant/.ssh/id_rsa
