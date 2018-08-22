# Use this file for variable that can change by environment

namespace = "example"
datacenter = "dc1"
aws_region = "us-east-1"
aws_access_key = ""
aws_secret_key = ""
consul_join_tag_value = "training"
public_key_path = "us-east-1.pub" 
# download the public key to the root of this project


# Instances configurations ($$)
nomad_bootstrap_expect = 1
nomad_server_instance_type = "t2.nano"
consul_bootstrap_expect = 1
nomad_server_instance_type = "t2.nano"
app_count = 2
application_instance_type = "t2.nano"
