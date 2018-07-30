data "template_file" "consul_server" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/consul_server.sh.tpl")}"
  
  vars {
    consul_version = "${var.consul_version}"
    consul_home = "${var.consul_home}"
    namespace = "${var.namespace}"
    bootstrap_expect = 3
    index = "${count.index}"
    consul_join_tag_value = "${var.consul_join_tag_value}"
  }
}

# Create the Consul cluster
resource "aws_instance" "consul_server" {
  count = "${var.servers}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.consul.id}"

  subnet_id              = "${element(aws_subnet.consul.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}"]

  tags = "${map(
    "Name", "${var.namespace}-consul-server-${count.index}",
    var.consul_join_tag_key, var.consul_join_tag_value
  )}"

  user_data = "${element(data.template_file.consul_server.*.rendered, count.index)}"
}

output "consul_servers" {
  value = ["${aws_instance.consul_server.*.public_ip}"]
}
