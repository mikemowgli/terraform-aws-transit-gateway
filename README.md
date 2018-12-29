AWS Transit Gateway scenario with Terraform
===========================================

This project gives an example of the usage of the recently (november 2018) announced [AWS Transit Gateway](https://aws.amazon.com/transit-gateway/) product. That component provides a way to interconnect multiple VPCs in a hub-spoke topology.

The Transit Gateway is meant to superseed the more complex and expensive Transit VPC technology. This is a didactic example to showcase how a Transit VPC should be configured to achieve a non-trivial (full mesh) scenario. I hope it can be helpful.

Architecture
------------

A Transit Gateway relies on Route Tables. By default, a new Route Table is created in the Transit Gateway, which populates with the routing info toward every VPC attached to the gateway (the full mesh scenario)
The Terraform code in this project demonstrates a more complex scenario in which traffic is isolated based on the environment. Four VPCs are created, with two subnets each (in separate AZs):
* VPC-1: in the 'dev' environment
* VPC-2: in the 'dev' environment
* VPC-3: in the 'shared' environment
* VPC-4: in the 'prod' environment

Let's assume the 'shared' environment will host shared components, such as proxy services, tools, ... Here are the rules we want our Transit Gateway to implement:
* The shared VPC can access dev and prod VPCs.
* The dev VPCs can access each other, and the shared VPC
* The prod VPCs can only access the shared VPC

To enable such a scenario, three Route Tables are created in the Transit Gateway, one per environment. Which means both dev VPCs attach to the same Route Table, whereas the shared and prod VPCs each attach to their respective Route Table. Each VPC gets a t2.micro Ubuntu instance to validate the network connectivity over ssh and ICMP (ping)

![transit-gateway-architecture](./doc/transit-gateway.png?raw=true "Transit Gateway Architecture")

Usage
-----


* Change ACCESS_KEY and SECRET_KEY values in Variables.tf
* Change the public_key value to a keypair you own
* Deploy the setup with:
```sh
$ terraform init
$ terraform plan
$ terraform apply
```
* The public IP of the instance in the 'shared' VPC is printed when deployment ends
* ssh on this instance
```sh
$ ssh -i your_private_key ubuntu@$PUBLIC_IP
```
* Check you can ping and ssh any other instance in the other VPCs
* Also check that, from a dev instance (1 & 2) you cannot reach the prod instance (4) and vice-versa.
* Delete all resources
```sh
$ terraform destroy
```
