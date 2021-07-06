  # Create a new rancher2 RKE Cluster
resource "rancher2_cluster" "app_cluster" {
  name = var.cluster_name
  description = "Application Cluster RKE"
  rke_config {
    network {
      plugin = "canal"
    }
  }
}

resource "null_resource" "controlplane_provision" {

  count = length(var.controlplane)

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "sudo usermod -aG docker ubuntu",
      "${rancher2_cluster.app_cluster.cluster_registration_token.0.node_command} --controlplane --etcd"
    ]
  }

  connection {
    type     = "ssh"
    user     = var.controlplane[count.index].ssh_user
    private_key = var.controlplane[count.index].private_key
    host     = var.controlplane[count.index].ip_address
  }
}

resource "null_resource" "workers_provision" {

  count = length(var.workers)

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io",
      "sudo usermod -aG docker ubuntu",
      "${rancher2_cluster.app_cluster.cluster_registration_token.0.node_command} --worker"
    ]
  }

  connection {
    type     = "ssh"
    user     = var.workers[count.index].ssh_user
    private_key = var.workers[count.index].private_key
    host     = var.workers[count.index].ip_address
  }
}
