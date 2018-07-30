data "template_file" "nomad_server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/nomad_server.sh.tpl")}"
  
  vars {
    consul_version = "${var.consul_version}"
    consul_home = "${var.consul_home}"
    namespace = "${var.namespace}"
    index = "${count.index}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
    nomad_home = "${var.nomad_home}"
    bootstrap_expect = "${var.nomad_bootstrap_expect}"
  }
}

data "template_file" "app_server" {
  count    = "${var.clients}"
  template = "${file("${path.module}/templates/app_server.sh.tpl")}"
  
  vars {
    consul_version = "${var.consul_version}"
    consul_home = "${var.consul_home}"
    namespace = "${var.namespace}"
    index = "${count.index}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
    nomad_home = "${var.nomad_home}"
  }
}

# Create the Nomad server (that includes nomad server and consul client)
resource "aws_instance" "nomad_server" {
  count = "${var.servers}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.application_instance_type}"
  key_name      = "${aws_key_pair.consul.id}"

  subnet_id              = "${element(aws_subnet.consul.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]

  tags = "${map(
    "Name", "${var.namespace}-nomad-server-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
  )}"

  user_data = "${element(data.template_file.nomad_server.*.rendered, count.index)}"
}


# Create application server (that includes nomad client and consul client)
resource "aws_instance" "app_server" {
  count = "${var.clients}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.consul.id}"

  subnet_id              = "${element(aws_subnet.consul.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]

  tags = "${map(
    "Name", "${var.namespace}-application-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
  )}"

  user_data = "${element(data.template_file.app_server.*.rendered, count.index)}"
}

output "nomad_servers" {
  value = ["${aws_instance.nomad_server.*.public_ip}"]
}

output "app_server" {
  value = ["${aws_instance.app_server.*.public_ip}"]
}
