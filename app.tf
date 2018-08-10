data "template_file" "app" {
  template = "${file("${path.module}/templates/app.sh.tpl")}"
  
  vars {
    consul_version = "${var.consul_version}"
    consul_home = "${var.consul_home}"
    namespace = "${var.namespace}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
    nomad_home = "${var.nomad_home}"
  }
}

resource "aws_launch_configuration" "app" {
  name_prefix          = "app"
  image_id             = "${data.aws_ami.ubuntu-1604.id}"
  instance_type        = "${var.application_instance_type}"
  key_name             = "${aws_key_pair.consul.id}"
  security_groups      = ["${aws_security_group.consul.id}"]
  user_data            = "${data.template_file.app.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.consul-join.name}"

  root_block_device {
    delete_on_termination = "1"
    volume_type           = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name                 = "app"
  max_size             = "${var.app_count}"
  min_size             = 2
  desired_capacity     = 2
  health_check_type    = "EC2"
  termination_policies = ["NewestInstance", "ClosestToNextInstanceHour"]
  launch_configuration = "${aws_launch_configuration.app.name}"

  vpc_zone_identifier = ["${aws_subnet.consul.*.id}"]

  depends_on = [
    "aws_route.internet_access",
    "aws_instance.consul_server",
    "aws_instance.nomad_server"
  ]
  
  tags = [
    {
      key                 = "Name"
      value               = "${var.namespace}-app"
      propagate_at_launch = true
    },{
      key                 = "${var.consul_join_tag_key}"
      value               = "${var.consul_join_tag_value}"
      propagate_at_launch = true
    }
  ]
}
