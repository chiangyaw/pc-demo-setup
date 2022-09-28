#! /bin/bash
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done
sudo apt update -y
sudo apt install docker.io -y
sudo apt install curl -y
sudo systemctl start docker
sudo systemctl enable docker
sudo groupadd docker 
sudo usermod -aG docker $USER

