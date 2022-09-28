#! /bin/bash
docker build -t jenkins_docker /tmp/jenkins_docker/
#sudo docker run -d -p 8080:8080 --name=jenkins_docker -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker --restart always jenkins_docker
sudo docker run -d -p 8080:8080 --name=jenkins_docker -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --restart always jenkins_docker
