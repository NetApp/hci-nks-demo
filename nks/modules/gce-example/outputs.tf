output "cluster_id" {
  value = "${nks_cluster.terraform-cluster.id}"
}


output "cluster_public_ips" {
  value = "${nks_cluster.terraform-cluster.nodes}"
}
