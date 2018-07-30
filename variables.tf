variable "aws_region" {
  description = "AWS region to create the environment"
}

variable "aws_access_key" {
  description = "AWS access key for account"
}

variable "aws_secret_key" {
  description = "AWS secret for account"
}

variable "consul_server_instance_type" { default = "t2.nano" }
variable "nomad_server_instance_type" { default = "t2.nano" }
variable "application_instance_type" { default = "t2.nano" }


variable "namespace" {
  description = <<EOH
The namespace to create the virtual training lab. This should describe the
training and must be unique to all current trainings. IAM users, workstations,
and resources will be scoped under this namespace.

It is best if you add this to your .tfvars file so you do not need to type
it manually with each run
EOH
}
variable "app_server_count" {
  description = "The number of application instances (that contains Nomad client and Consul client)"
}

variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.2.1"
}

variable "consul_home" { 
  default = "/consul"
}
variable "nomad_home" { 
  default = "/nomad"
}

variable "nomad_bootstrap_expect" { }
variable "consul_bootstrap_expect" { }

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "consul_join_tag_key" {
  description = "The key of the tag to auto-jon on EC2."
  default     = "consul_join"
}

variable "consul_join_tag_value" {
  description = "The value of the tag to auto-join on EC2."
  default     = "training"
}

variable "public_key_path" {
  description = "The absolute path on disk to the SSH public key."
  default     = "us-east-1.pub"
}
