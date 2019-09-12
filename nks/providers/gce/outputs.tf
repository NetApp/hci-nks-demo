output "node_info" {
  value = "${module.main.cluster_public_ips}"
}

output "cluster_id" {
  value = "${module.main.cluster_id}"
}
