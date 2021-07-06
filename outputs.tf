output "kubeconfig" {
    description = "KUBECONFIG file generated by Rancher for the Downstream Cluster"
    value = rancher2_cluster.app_cluster.kube_config
    sensitive = true
}