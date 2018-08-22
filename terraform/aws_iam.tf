resource "aws_key_pair" "consul" {
  key_name   = "${var.namespace}KeyPair"
  public_key = "${file("./${var.public_key_path}")}"
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "${var.namespace}-consul-join"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role.json")}"
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "${var.namespace}-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "${var.namespace}-consul-join"
  role = "${aws_iam_role.consul-join.name}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "${var.namespace}-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}
