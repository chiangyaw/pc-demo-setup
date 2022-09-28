FROM jenkins/jenkins:lts-jdk11

USER root
RUN apt-get update \
      && apt-get install -y sudo libltdl7 \
      && rm -rf /var/lib/apt/lists/*
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /var/tmp/awscliv2.zip
RUN unzip /var/tmp/awscliv2.zip -d /var/tmp/
RUN /var/tmp/aws/install
RUN curl https://get.docker.com/ > /var/tmp/dockerinstall && chmod 777 /var/tmp/dockerinstall && /var/tmp/dockerinstall
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && mv kubectl /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers