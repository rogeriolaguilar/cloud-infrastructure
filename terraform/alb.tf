// # This is not the better way to do external load balacing for instances with Nomad/Consul stack, 
// # For a better strategies see https://www.hashicorp.com/blog/load-balancing-strategies-for-consul

resource "aws_alb" "app" {
  name = "${var.namespace}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_app.id}"]
  subnets            = ["${aws_subnet.consul.*.id}"]
}


resource "aws_alb_listener" "app" {
  load_balancer_arn = "${aws_alb.app.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
}

resource "aws_security_group" "alb_app" {
  name = "${var.namespace}-alb-app"
  vpc_id = "${aws_vpc.consul.id}"
  description = "allow HTTP to ${var.namespace}-alb Load Balancer (ALB)"
  ingress {
      from_port = "80"
      to_port = "80"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "app" {
	name = "${var.namespace}-alb-app"
	vpc_id	= "${aws_vpc.consul.id}"
	port	= "80"
	protocol	= "HTTP"
	health_check {
                path = "/"
                protocol = "HTTP"
                healthy_threshold = 5
                unhealthy_threshold = 2
                interval = 5
                timeout = 4
                matcher = "200"
        }
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = "${aws_autoscaling_group.app.id}"
  alb_target_group_arn   = "${aws_alb_target_group.app.arn}"
}
