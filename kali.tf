resource "aws_network_interface" "attacker_kali_eni" {
  subnet_id = aws_subnet.attacker_a_sub.id

  # the security group
  security_groups = [aws_security_group.attacker_sg.id]

  tags = {
    Name = "${var.unique_prefix}_attacker_kali_eni"
  }
}

resource "aws_instance" "attacker_kali" {
  # subscribe kali https://aws.amazon.com/marketplace/pp/prodview-fznsw3f7mq7to
  ami = "ami-03536d8ed3f977563"
  instance_type = "t2.medium"

  network_interface {
    network_interface_id = aws_network_interface.attacker_kali_eni.id
    device_index = 0
  }

  root_block_device {
    volume_size = 40
    delete_on_termination = true
  }

  # the public SSH key
  key_name                    = aws_key_pair.keypair.key_name

  connection {
    user = "kali"
    host = aws_instance.attacker_kali.public_ip
    private_key = file("${aws_key_pair.keypair.key_name}.pem")
  }

  provisioner "file" {
    source = "scripts/kali-install.sh"
    destination = "/tmp/kali-install.sh"
  }

  provisioner "file" {
    source = "vuln_app/exploit.sh"
    destination = "/tmp/exploit.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kali-install.sh",
      "/tmp/kali-install.sh",
    ]
  }

  tags = {
    Name   = "${var.unique_prefix}_attacker_kali"
    DND = "DND"
    StatusDND = "DND"
  }
}