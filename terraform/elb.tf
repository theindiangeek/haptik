resource "aws_elb" "api" {
  name               = "api-master"
  #https://github.com/terraform-providers/terraform-provider-aws/issues/1497
  #Avoid AZs, use subnet else it will use the default subnet since we have not specified any network for the ELB.
  #availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  subnets = ["${aws_subnet.vpc-1a-public.id}", "${aws_subnet.vpc-1b-public.id}", "${aws_subnet.vpc-1c-public.id}"]

  listener {
    instance_port     = 6443
    instance_protocol = "TCP"
    lb_port           = 6443
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:6443"
    interval            = 10
  }

  instances                   = ["${aws_instance.master-1a.id}", "${aws_instance.master-1b.id}", "${aws_instance.master-1c.id}"]
  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups = ["${aws_security_group.k8s.id}"]

  tags = {
    Name = "api-master"
  }
}
