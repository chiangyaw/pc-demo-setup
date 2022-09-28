resource "aws_subnet" "panw_docker_a_sub" {
  vpc_id        = aws_vpc.panw_docker_vpc.id
  cidr_block    = cidrsubnet(var.panw_docker_vpc, 8, 1)
  map_public_ip_on_launch = "true"
  availability_zone = "${var.region}a"
  tags          = {
    Name = "${var.unique_prefix}_panw_docker_sub_1"
  }
}

resource "aws_subnet" "panw_eks_sub" {
  count             = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.panw_eks_vpc.id
  cidr_block        = cidrsubnet(var.panw_eks_vpc, 8, count.index)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.unique_prefix}_panw_eks_sub_${count.index + 1}"
  }
}

resource "aws_subnet" "attacker_a_sub" {
  vpc_id        = aws_vpc.attacker_vpc.id
  cidr_block    = cidrsubnet(var.attacker_vpc, 8, 1)
  map_public_ip_on_launch = "true"
  availability_zone = "${var.region}a"
  tags          = {
    Name = "${var.unique_prefix}_attacker_sub_1"
  }
}