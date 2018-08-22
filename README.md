# AWS Cloud Infrastructure using Nomad and Consul

The versions was updated to:

- Terraform v0.11.7
- Consul v1.2.2
- Nomad 0.8.4

This repository has a sample nomad job define in `./nomad/hello.nomad`. When you conclude the creation of the cluster that application can be deploy using the `./deploy.sh` script.

Before all run `./terraform.sh init`

To start and bootstrap the cluster modify the file terraform.tfvars or set the environment variables to add your AWS credentials and default region

```bash
$ export AWS_SECRET_ACCESS_KEY='???'
$ export AWS_DEFAULT_REGION='???'
$ export AWS_ACCESS_KEY_ID='???'
```

Then create a AWS access key ( see https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html )


Run `./terraform.sh plan`, `./terraform.sh apply` to create the cluster.

Once this is all up and running, you will see some output from Terraform showing the IP addresses of the created agents and servers.

## Nomad UI

In the Nomad web interface you can see your infra!: http://[nomad-server-ip]:4646

You can find the nomad server IPs with:

```bash
$ terraform output nomad_servers
34.235.121.160,
18.207.108.144,
34.204.79.13
```


## Scale up
The cluster automatically bootstrapped with no human intervention, to simulate a failure scenario or scaling of the cluster again modify the `terraform.tfvars` file, change the number of instances and then re-run `./terraform.sh plan` and `terraform apply`.

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
To deploy a sample application run de `deploy.sh` script using as argument the name of the nomad file (without extension)

```
$ ./deploy.sh 'hello'
```

In Nomad UI you can see that the job was deployed.


## Cleanup
Do not forget to clean up after the example.  Running `./terraform.sh destroy` will remove all resources created by this example.
