data "aws_ami" "aws_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"]
}

resource "aws_network_interface" "panw_instance_eni" {
  subnet_id = aws_subnet.panw_docker_a_sub.id
  #private_ips = ["10.0.2.160"]

  # the security group
  security_groups = [aws_security_group.panw_docker_sg.id]

  tags = {
    Name = "${var.unique_prefix}_panw_bastian_eni"
  }
}

resource "aws_instance" "panw_instance" {
  ami                         = data.aws_ami.aws_ubuntu.id
  instance_type               = "t2.medium"
  # subnet_id                   = aws_subnet.panw_a_sub.id
  key_name                    = aws_key_pair.keypair.key_name
  #associate_public_ip_address = "true"
  #vpc_security_group_ids      = [aws_security_group.panw_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.panw_docker_profile.name
  network_interface {
    network_interface_id = aws_network_interface.panw_instance_eni.id
    device_index = 0
  }
  root_block_device{
      volume_size = 100
      volume_type = "gp2"
    }

#   user_data = <<-BOOTSTRAP
# sudo apt-get update
# sudo apt-get upgrade -y
# sudo apt-get install apt-transport-https ca-certificates wget curl gnupg-agent software-properties-common jq -y
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io -y
# sudo usermod -aG docker $USER
# mkdir twistlock
# wget https://cdn.twistlock.com/releases/wvwmqccy/prisma_cloud_compute_edition_22_06_179.tar.gz
# tar -xzf prisma_cloud_compute_edition_22_06_179.tar.gz -C twistlock/
# BOOTSTRAP
  connection {
    user = "ubuntu"
    host = aws_instance.panw_instance.public_ip
    private_key = file("${aws_key_pair.keypair.key_name}.pem")
  }

  provisioner "file" {
    source = "scripts/docker-install.sh"
    destination = "/tmp/docker-install.sh"
  }

  provisioner "file" {
    source = "scripts/jenkins-install.sh"
    destination = "/tmp/jenkins-install.sh"
  }

  provisioner "file" {
    source = "vuln_app"
    destination = "/tmp/vuln_app"
  }

  provisioner "file" {
    source = "jenkins_docker"
    destination = "/tmp/jenkins_docker"
  }

  # provisioner "file" {
  #   source = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${var.cluster_name}" : var.config_output_path
  #   destination = "/tmp/kubeconfig_${var.cluster_name}"
  # }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/docker-install.sh",
      "/tmp/docker-install.sh",
      # "docker build -t jenkins_docker /tmp/jenkins_docker/",
      # "sudo docker run -d -p 8080:8080 --name=jenkins_docker -v jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker --restart always jenkins_docker"
    ]
  }



  tags = {
    Name   = "${var.unique_prefix}-panw_docker"
    DND = "DND"
    StatusDND = "DND"
  }
}

# resource "aws_eip" "panw_eip" {
#   instance = aws_instance.panw_instance.id
#   vpc      = true
# }


resource "aws_iam_role" "panw_docker_role" {
  name = "${var.unique_prefix}-panw-docker-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "panw_docker_ecr_policy" {
  name = "${var.unique_prefix}-panw-docker-ecr-policy"
  role = aws_iam_role.panw_docker_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetRegistryPolicy",
          "ecr:CreateRepository",
          "ecr:DescribeRegistry",
          "ecr:DescribePullThroughCacheRules",
          "ecr:GetAuthorizationToken",
          "ecr:PutRegistryScanningConfiguration",
          "ecr:CreatePullThroughCacheRule",
          "ecr:DeletePullThroughCacheRule",
          "ecr:PutRegistryPolicy",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:BatchImportUpstreamImage",
          "ecr:DeleteRegistryPolicy",
          "ecr:PutReplicationConfiguration"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "panw_docker_eks_policy" {
  name = "${var.unique_prefix}-panw-docker-eks-policy"
  role = aws_iam_role.panw_docker_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi",
          "eks:ListAddons",
          "eks:DescribeCluster",
          "eks:DescribeAddonVersions",
          "eks:ListClusters",
          "eks:ListIdentityProviderConfigs",
          "iam:ListRoles"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ssm:GetParameter",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
      },
    ]
  })
}


resource "aws_iam_instance_profile" "panw_docker_profile" {
  name = "${var.unique_prefix}-panw-docker-profile"
  role = "${aws_iam_role.panw_docker_role.name}"
}