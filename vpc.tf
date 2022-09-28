resource "aws_vpc" "panw_eks_vpc" {
  cidr_block = var.panw_eks_vpc
  tags = {
    Name = "${var.unique_prefix}_panw_eks_vpc"
  }
}

resource "aws_vpc" "panw_docker_vpc" {
  cidr_block = var.panw_docker_vpc
  tags = {
    Name = "${var.unique_prefix}_panw_docker_vpc"
  }
}

resource "aws_vpc" "attacker_vpc" {
  cidr_block = var.attacker_vpc
  tags = {
    Name = "${var.unique_prefix}_attacker_vpc"
  }
}