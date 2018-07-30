data "template_file" "app_server" {
  count    = "${var.app_server_count}"
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

# Create application server (it includes nomad client and consul client)
resource "aws_instance" "app_server" {
  count = "${var.app_server_count}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.application_instance_type}"
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

output "app_server" {
  value = ["${aws_instance.app_server.*.public_ip}"]
}
