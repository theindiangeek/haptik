resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_eip" "eip_for_nat_gateway-1a" {
  vpc = true
}

resource "aws_eip" "eip_for_nat_gateway-1b" {
  vpc = true
}

resource "aws_eip" "eip_for_nat_gateway-1c" {
  vpc = true
}

resource "aws_nat_gateway" "gw-1a" {
  allocation_id = "${aws_eip.eip_for_nat_gateway-1a.id}"
  subnet_id     = "${aws_subnet.vpc-1a-public.id}"
}

resource "aws_nat_gateway" "gw-1b" {
  allocation_id = "${aws_eip.eip_for_nat_gateway-1b.id}"
  subnet_id     = "${aws_subnet.vpc-1b-public.id}"
}

resource "aws_nat_gateway" "gw-1c" {
  allocation_id = "${aws_eip.eip_for_nat_gateway-1c.id}"
  subnet_id     = "${aws_subnet.vpc-1c-public.id}"
}

resource "aws_subnet" "vpc-1a-public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 8, 6)}"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "vpc-1b-public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 8, 8)}"
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "vpc-1c-public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 8, 10)}"
  availability_zone = "${var.region}c"
}

resource "aws_subnet" "vpc-1a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 8, 0)}"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "vpc-1b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 8, 2)}"
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "vpc-1c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.cidr, 8, 4)}"
  availability_zone = "${var.region}c"
}

resource "aws_route_table" "rt-public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }
}

resource "aws_route_table" "rt-private-1a" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw-1a.id}"
  }
}

resource "aws_route_table" "rt-private-1b" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw-1b.id}"
  }
}

resource "aws_route_table" "rt-private-1c" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw-1c.id}"
  }
}

# ROUTING table asccociation
resource "aws_route_table_association" "rta-1a" {
  subnet_id      = "${aws_subnet.vpc-1a.id}"
  route_table_id = "${aws_route_table.rt-private-1a.id}"
}

resource "aws_route_table_association" "rta-1b" {
  subnet_id      = "${aws_subnet.vpc-1b.id}"
  route_table_id = "${aws_route_table.rt-private-1b.id}"
}

resource "aws_route_table_association" "rta-1c" {
  subnet_id      = "${aws_subnet.vpc-1c.id}"
  route_table_id = "${aws_route_table.rt-private-1c.id}"
}

resource "aws_route_table_association" "rta-1a-public" {
  subnet_id      = "${aws_subnet.vpc-1a-public.id}"
  route_table_id = "${aws_route_table.rt-public.id}"
}

resource "aws_route_table_association" "rta-1b-public" {
  subnet_id      = "${aws_subnet.vpc-1b-public.id}"
  route_table_id = "${aws_route_table.rt-public.id}"
}

resource "aws_route_table_association" "rta-1c-public" {
  subnet_id      = "${aws_subnet.vpc-1c-public.id}"
  route_table_id = "${aws_route_table.rt-public.id}"
}
