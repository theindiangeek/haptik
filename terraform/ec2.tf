provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_eip" "eip_for_bastion" {
  vpc = true
}

resource "aws_eip_association" "bastion" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.eip_for_bastion.id}"
}

data "aws_ami" "ami" {
most_recent       = true
  owners            = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*-x86_64-gp2"]
  }
}

locals {
  instance-userdata = <<EOF
#!/bin/bash
sudo cat <<REPO > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
REPO

sudo yum install docker kubelet-1.16.15 kubectl-1.16.15 kubeadm-1.16.15 -y --nogpgcheck

sudo modprobe br_netfilter
sudo swapoff -a

echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-ip6tables = 1 >> /etc/sysctl.conf
echo net.bridge.bridge-nf-call-iptables = 1 >> /etc/sysctl.conf
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
sudo modprobe br_netfilter

sudo sysctl -p

sudo service docker start
EOF
}

resource "aws_instance" "master-1a" {
  #ami           = "${var.ami_id}"
  ami           = "${data.aws_ami.ami.id}"
  instance_type = "t3.medium"
  subnet_id = "${aws_subnet.vpc-1a.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s.id}"]
  key_name = "${aws_key_pair.key.id}"
  user_data_base64 = "${base64encode(local.instance-userdata)}"
  depends_on = ["aws_route_table_association.rta-1a", "aws_route_table_association.rta-1a", "aws_route_table_association.rta-1c"]
  tags = {
    Name = "master-1a"
  }
}

resource "aws_instance" "master-1b" {
  ami           = "${data.aws_ami.ami.id}"
  instance_type = "t3.medium"
  subnet_id = "${aws_subnet.vpc-1b.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s.id}"]
  key_name = "${aws_key_pair.key.id}"
  user_data_base64 = "${base64encode(local.instance-userdata)}"
  depends_on = ["aws_route_table_association.rta-1a", "aws_route_table_association.rta-1a", "aws_route_table_association.rta-1c"]
  tags = {
    Name = "master-1b"
  }
}

resource "aws_instance" "master-1c" {
  ami           = "${data.aws_ami.ami.id}"
  instance_type = "t3.medium"
  subnet_id = "${aws_subnet.vpc-1c.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s.id}"]
  key_name = "${aws_key_pair.key.id}"
  user_data_base64 = "${base64encode(local.instance-userdata)}"
  depends_on = ["aws_route_table_association.rta-1a", "aws_route_table_association.rta-1a", "aws_route_table_association.rta-1c"]
  tags = {
    Name = "master-1c"
  }
}

resource "aws_instance" "worker" {
  ami           = "${data.aws_ami.ami.id}"
  instance_type = "t3.medium"
  subnet_id = "${aws_subnet.vpc-1a.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s.id}"]
  key_name = "${aws_key_pair.key.id}"
  user_data_base64 = "${base64encode(local.instance-userdata)}"
  depends_on = ["aws_route_table_association.rta-1a", "aws_route_table_association.rta-1a", "aws_route_table_association.rta-1c"]
  tags = {
    Name = "worker"
  }
}

resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.ami.id}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.vpc-1a-public.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s.id}"]
  key_name = "${aws_key_pair.key.id}"
  associate_public_ip_address = "true"
  tags = {
    Name = "bastion"
  }
}

resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8IFxCcBW+uubzCxMNzKC6O4y1gkjhVonFFvSsadOGgnhe6JGLb5y64VL9EICvilcjGdxk6g/KrbbJU0APb/LEayJWxED5NcuN9aYm1N3dlFUVy6wIDGxv7bDyolQ0mcYTByunMTEpQEpXkMC+9wN50q3clFJxmxRxIyeIVzYDIqmvvbRZFUfVe/mdmd/uJls6fHT0U1NVCs1DQXOGmyddanvev+f1VjiiN0t/Rv0vpfBbwVgqi2/m4ksZn/IdAzEIBJ/cYbpURISKPJF+Qas/yWABpqIT7Yon9yXoIHjVbhAjuA5nhQ3SzBxBuElNCLPWK58fjWohQ3bvX1fZ75w1 shardool@Shardool-DevOps.local"
}
