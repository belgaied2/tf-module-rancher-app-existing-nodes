variable "api_url" {
  type        = string
  description = "URL for Rancher's API"
}

variable "token_key" {
  type = string
  description = "Token key from Rancher for Terraform's user"
}

variable "cluster_name" {
  type = string
  description = "Desired name for the Downstream Cluster"
  default = "downstream-test"
}


variable "workers" {
  description = "List of Worker nodes objects including: IP address, SSH private key, SSH User and SSH port"
  type = list(object({
    ip_address = string
    private_key = string
    ssh_port = number
    ssh_user = string
  }))
  default = [ 
    {
      ip_address = ""
      private_key = ""
      ssh_port = 22
      ssh_user = "ubuntu"
    } 
  ]
}

variable "controlplane" {
  description = "List of control plane nodes objects including: IP address, SSH private key, SSH User and SSH port"
  type = list(object({
    ip_address = string
    private_key = string
    ssh_port = number
    ssh_user = string
  }))
  default = [ 
    {
      ip_address = ""
      private_key = ""
      ssh_port = 22
      ssh_user = "ubuntu"
    } 
  ]
}