provider "nks" {
  
}


module "main" {
  source = "./modules/gce-example"

  organization_name         = "${var.organization_name}"
  cluster_name              = "${var.cluster_name}"

  provider_keyset_name      = "${var.provider_keyset_name}"
  ssh_keyset_name           = "${var.ssh_keyset_name}"

  provider_code             = "${var.provider_code}"
  provider_k8s_version      = "${var.provider_k8s_version}"
  provider_platform         = "${var.provider_platform}"
  provider_region           = "${var.provider_region}"
  provider_network_id       = "${var.provider_network_id}"
  provider_network_cidr     = "${var.provider_network_cidr}"
  provider_subnet_id        = "${var.provider_subnet_id}"
  provider_subnet_cidr      = "${var.provider_subnet_cidr}"
  provider_master_size      = "${var.provider_master_size}"
  provider_worker_size      = "${var.provider_worker_size}"
  provider_channel          = "${var.provider_channel}"
  provider_etcd_type        = "${var.provider_etcd_type}"
  
}
