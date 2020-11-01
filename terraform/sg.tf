resource "aws_security_group" "k8s" {
  name        = "k8s"
  description = "Allow inter master node communication and worker nodes"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description = "Allow inter master node communication and worker nodes"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${aws_eip.eip_for_nat_gateway-1c.public_ip}/32", "${aws_eip.eip_for_nat_gateway-1b.public_ip}/32", "${aws_eip.eip_for_nat_gateway-1a.public_ip}/32"]
  }

  ingress {
    description = "Allow inter master node communication and worker nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  ingress {
    description = "My public IP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["182.75.158.222/32", "111.93.45.50/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s"
  }
}
