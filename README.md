<!-- BEGIN_TF_DOCS -->
# Terraform module for Application Clusters using Rancher

## Introduction
This is repository for automating the creation of a Kubernetes Application Cluster using Rancher and existing nodes. This is known as the *custom* approach to provision clusters. Sometimes, Rancher Operation teams do not have access to an Infrastructure as a Service (IaaS) provider to provision their own infrastructure. They only get access to pre-provisioned nodes made available by another team in the organization.
That's whom this repository is destined to.

## Description of this Terraform Configuration
This Terraform configuration will use the [Rancher2 provider for Terraform](https://registry.terraform.io/providers/rancher/rancher2/latest/docs) to communicate with Rancher's API and define a downstream cluster (sometimes also called workload cluster or application cluster). It also connects to existing machines to run the Docker bootstrapping command necessary to deploy Kubernetes components on these nodes.

This approach corresponds to the one described in [these Rancher documentation pages](https://rancher.com/docs/rancher/v2.x/en/cluster-provisioning/rke-clusters/custom-nodes/).

## Pre-requisites
In order for this Terraform module to run correctly, you need a number of machines with a pre-defined number destined to be control plane nodes and a pre-defined number destined to be worker nodes.

Now, the nodes can be Ubuntu, CentOS or some other distribution. However, this configuration was only tested on Ubuntu 20.04 and CentOS 7.9 nodes. Any contribution in this regards would be appreciated. If your machines are based on another Linux distribution, please do not hesitate to fork this repository and do the necessary modifications in the file [rcluster.tf](./rcluster.tf#38) under the `provisioner` section in each `null_resource` resource.

The following data is necessary as an input to this module:
- API URL for accessing Rancher, e.g. https://rancher.my.domain/v3/
- API Token from the Rancher user you plan to use for Terraform
- List of nodes with their:
    - IP Address
    - SSH User
    - Content in Base64 PEM format (remember that it is possible to use the Terraform function `file()` to read the content from a file)
    - SSH Port 

## How-To

### Inputs

In order to make this configuration work, you will need to provide the inputs described above as Terraform variables. To achieve this, you can use the example file [terraform.tfvars.example](./terraform.tfvars.example).

The nodes are organized in two different lists:
- one `controlplane` list of nodes on which the RKE roles *controlplane* and *etcd* will be deployed
- one `workers` list of nodes on which the RKE role *worker* will be deployed

More on the concept of RKE roles [here](https://rancher.com/docs/rke/latest/en/config-options/nodes/#kubernetes-roles).

### Backend
Terraform manages a state file to describe the current infrastructure status. This state file will by default be local, but this is a bad practice especially if you work as a team and/or use multiple machines to run Terraform from.

It is recommended to use a [remote backend to store the Terraform state](https://www.terraform.io/docs/language/state/remote.html). 

## Run the configuration
Since this configuration is formatted as a module, you can use it from you own configuration using as an example:

```hcl
module "cluster" {
    source = "github.com/belgaied2/tf-module-rancher-app-existing-nodes"
    api_url = "https://rancher.com/v3"
    token_key = "token-abcde:longstring"
    workers = [
        {
            ip_address          = "10.1.1.1"
            private_key_path    = <<-EOT
                -----BEGIN PRIVATE KEY-----
                <PRIVATE_KEY_CONTENT_BASE64>
                -----END PRIVATE KEY-----
            EOT
            ssh_user            = "ubuntu"
            ssh_port            = 22
        },
        {
            ip_address          = "10.1.1.11"
            private_key_path    = <<-EOT
                -----BEGIN PRIVATE KEY-----
                <PRIVATE_KEY_CONTENT_BASE64>
                -----END PRIVATE KEY-----
            EOT
            ssh_user            = "ubuntu"
            ssh_port            = 22
        }
        ]
    controlplane =[

        {
            ip_address          = "10.1.1.12"
            private_key_path    = <<-EOT
                -----BEGIN PRIVATE KEY-----
                <PRIVATE_KEY_CONTENT_BASE64>
                -----END PRIVATE KEY-----
            EOT
            ssh_user            = "ubuntu"
            ssh_port            = 22
        }
    ]
}
``` 
As a module, this configuration exports the kubeconfig file as an output, making it possible to use it further to provision applications in the cluster, using the [Kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest) and [Helm](https://registry.terraform.io/providers/hashicorp/helm/latest) providers for Terraform.


You can also clone this configuration locally and do your own modifications:
```bash
$ git clone https://github.com/belgaied2/tf-module-rancher-app-existing-nodes.git
```
Then, rename the file `terraform.tfvars.example` into `terraform.tfvars` and edit it with your own values.

# Terraform-related documentation

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | 1.15.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | 1.15.1 |

## Modules

No modules are used inside this module.

## Resources

| Name | Type |
|------|------|
| [null_resource.controlplane_provision](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.workers_provision](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [rancher2_cluster.app_cluster](https://registry.terraform.io/providers/rancher/rancher2/1.15.1/docs/resources/cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_url"></a> [api\_url](#input\_api\_url) | URL for Rancher's API | `string` | n/a | yes |
| <a name="input_token_key"></a> [token\_key](#input\_token\_key) | Token key from Rancher for Terraform's user | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Desired name for the Downstream Cluster | `string` | `"downstream-test"` | no |
| <a name="input_controlplane"></a> [controlplane](#input\_controlplane) | List of control plane nodes objects including: IP address, SSH private key, SSH User and SSH port | <pre>list(object({<br>    ip_address = string<br>    private_key_path = string<br>    ssh_port = number<br>    ssh_user = string<br>  }))</pre> | <pre>[<br>  {<br>    "ip_address": "",<br>    "private_key_path": "",<br>    "ssh_port": 22,<br>    "ssh_user": "ubuntu"<br>  }<br>]</pre> | yes |
| <a name="input_workers"></a> [workers](#input\_workers) | List of Worker nodes objects including: IP address, SSH private key, SSH User and SSH port | <pre>list(object({<br>    ip_address = string<br>    private_key_path = string<br>    ssh_port = number<br>    ssh_user = string<br>  }))</pre> | <pre>[<br>  {<br>    "ip_address": "",<br>    "private_key_path": "",<br>    "ssh_port": 22,<br>    "ssh_user": "ubuntu"<br>  }<br>]</pre> | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | KUBECONFIG file generated by Rancher for the Downstream Cluster |
<!-- END_TF_DOCS -->