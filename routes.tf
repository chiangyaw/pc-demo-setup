resource "aws_internet_gateway" "panw_eks_igw" {
  vpc_id = aws_vpc.panw_eks_vpc.id

  tags = {
    Name = "${var.unique_prefix}_panw_eks_igw"
  }
}

resource "aws_internet_gateway" "panw_docker_igw" {
  vpc_id = aws_vpc.panw_docker_vpc.id

  tags = {
    Name = "${var.unique_prefix}_panw_docker_igw"
  }
}

resource "aws_internet_gateway" "attacker_igw" {
  vpc_id = aws_vpc.attacker_vpc.id

  tags = {
    Name = "${var.unique_prefix}_attacker_igw"
  }
}

resource "aws_route_table" "panw_docker_rt" {
  vpc_id = aws_vpc.panw_docker_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.panw_docker_igw.id
  }

  tags = {
    Name = "${var.unique_prefix}_panw_docker_rt"
  }
}

resource "aws_route_table" "panw_eks_rt" {
  vpc_id = aws_vpc.panw_eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.panw_eks_igw.id
  }

  tags = {
    Name = "${var.unique_prefix}_panw_eks_rt"
  }
}

resource "aws_route_table" "attacker_rt" {
  vpc_id = aws_vpc.attacker_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.attacker_igw.id
  }

  tags = {
    Name = "${var.unique_prefix}_attacker_rt"
  }
}

resource "aws_route_table_association" "panw_docker_sub_assoc" {
  subnet_id = aws_subnet.panw_docker_a_sub.id
  route_table_id = aws_route_table.panw_docker_rt.id
}


resource "aws_route_table_association" "panw_eks_sub_assoc" {
  count = length(data.aws_availability_zones.azs.names)
  subnet_id = element(aws_subnet.panw_eks_sub.*.id,count.index)
  route_table_id = aws_route_table.panw_eks_rt.id
}

resource "aws_route_table_association" "attacker_sub_assoc" {
  subnet_id = aws_subnet.attacker_a_sub.id
  route_table_id = aws_route_table.attacker_rt.id
}