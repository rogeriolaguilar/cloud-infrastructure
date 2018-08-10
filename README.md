# Nomad and Consul Auto-Join Example

Adding Nomad and updating consul version to the sample from project: https://github.com/hashicorp/consul-ec2-auto-join-example

The versions was updated to:
- Terraform v0.11.7
- Consul v1.2.1 

To start and bootstrap the cluster modify the file terraform.tfvars to add your AWS credentials and default region and then run `terraform plan`, `terraform apply` to create the cluster.

```
aws_region = "us-east-1"

aws_access_key = "AWS_ACCESS_KEY"

aws_secret_key = "AWS_SECRET"
```
or 

```
export AWS_SECRET_ACCESS_KEY=???
export AWS_DEFAULT_REGION=???
export AWS_ACCESS_KEY_ID=???

```

Once this is all up and running, you will see some output from Terraform showing the IP addresses of the created agents and servers.

```bash
Outputs:

clients = [
    34.253.136.132,
    34.252.238.49
]
servers = [
    34.251.206.78,
    34.249.242.227,
    34.253.133.165
]

```

After provisioning, it is possible to login to one of the client nodes via SSH using the IP address output from Terraform. 

```bash
$ ssh ubuntu@34.251.206.78
```

Running the `consul members` command will show all members of the cluster and their status (both clients and servers).

```bash
$ consul members
Node                  Address          Status  Type    Build  Protocol  DC
consul-client-0  10.1.1.189:8301  alive   client  1.2.1  2         dc1
consul-client-1  10.1.2.187:8301  alive   client  1.2.1  2         dc1
consul-server-0  10.1.1.241:8301  alive   server  1.2.1  2         dc1
consul-server-1  10.1.2.24:8301   alive   server  1.2.1  2         dc1
consul-server-2  10.1.1.26:8301   alive   server  1.2.1  2         dc1
```

## Nomad UI
To see Nomad UI: http://nomad-server-ip:4646

## Scale up
The cluster automatically bootstrapped with no human intervention, to simulate a failure scenario or scaling of the cluster again modify the `terraform.tfvars` file, increase the number of instances to 5 and then re-run `terraform plan` and terraform apply`.

```bash
$ terraform plan -var-file=terraform.tfvars
Plan: 2 to add, 0 to change, 0 to destroy.
...
```

```bash
$ terraform apply
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

clients = [
    34.253.136.132,
    34.252.238.49
]
servers = [
    34.251.206.78,
    34.249.242.227,
    34.253.133.165,
    34.252.132.0,
    34.253.148.148
]
```

Run `consul members` again after the new servers have finished provisioning. It might take a few seconds for the new servers to join the cluster, but they will be available in the memberlist:

```bash
Node                  Address          Status  Type    Build  Protocol  DC
consul-client-0  10.1.1.189:8301  alive   client  1.2.1  2         dc1
consul-client-1  10.1.2.187:8301  alive   client  1.2.1  2         dc1
consul-server-0  10.1.1.241:8301  alive   server  1.2.1  2         dc1
consul-server-1  10.1.2.24:8301   alive   server  1.2.1  2         dc1
consul-server-2  10.1.1.26:8301   alive   server  1.2.1  2         dc1
consul-server-3  10.1.2.44:8301   alive   server  1.2.1  2         dc1
consul-server-4  10.1.1.75:8301   alive   server  1.2.1  2         dc1
```

## Scale down
The same applies when scaling down - there is no need to manually remove nodes, so long as we stay above the originally-configured minimum number of servers (3 in this example). To demonstrate this functionality, decrease the number of servers in the `terraform.tfvars` file and run `terraform plan` and `terraform apply` again. The deprovisioned server nodes will show in the members list as failed, but the cluster will be fully operational.

```text
Node                  Address          Status  Type    Build  Protocol  DC
consul-client-0  10.1.1.189:8301  alive   client  1.2.1  2         dc1
consul-client-1  10.1.2.187:8301  alive   client  1.2.1  2         dc1
consul-server-0  10.1.1.241:8301  alive   server  1.2.1  2         dc1
consul-server-1  10.1.2.24:8301   alive   server  1.2.1  2         dc1
consul-server-2  10.1.1.26:8301   alive   server  1.2.1  2         dc1
consul-server-3  10.1.2.44:8301   failed  server  1.2.1  2         dc1
consul-server-4  10.1.1.75:8301   failed  server  1.2.1  2         dc1
```

## Deploy
To deploy a sample application run de `deploy.sh` script using as argument the public IP of the nomad server

```
./deploy.sh nomad-server-public-ip
```

In Nomad UI you can see that the job was deployed.


## Cleanup
Do not forget to clean up after the example.  Running `terraform destroy` will remove all resources created by this example.


