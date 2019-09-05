provider "nks" {
  # Set environment variable NKS_API_TOKEN with your API token from NKS
  # Set environment variable NKS_API_URL with API endpoint,   
  # defaults to NKS production enviroment.
}

data "nks_organization" "default" {
  name = "${var.organization_name}"
}

data "nks_keyset" "keyset_default" {
  # You can specify a custom orgID here or the system will find and use your
  # default organization ID.
  org_id   = "${data.nks_organization.default.id}"
  name     = "${var.provider_keyset_name}"
  category = "provider"
  entity   = "${var.provider_code}"
}

data "nks_keyset" "keyset_ssh" {
  # You can specify a custom orgID here or the system will find and use your
  # default organization ID.
  org_id   = "${data.nks_organization.default.id}"
  category = "user_ssh"
  name     = "${var.ssh_keyset_name}"
}

data "nks_instance_specs" "master-specs" {
  provider_code = "${var.provider_code}"
  node_size     = "${var.provider_master_size}"
}

data "nks_instance_specs" "worker-specs" {
  provider_code = "${var.provider_code}"
  node_size     = "${var.provider_worker_size}"
}

resource "nks_cluster" "terraform-cluster" {
  org_id                        = "${data.nks_organization.default.id}"
  cluster_name                  = "${var.cluster_name}"
  provider_code                 = "${var.provider_code}"
  provider_keyset               = "${data.nks_keyset.keyset_default.id}"
  region                        = "${var.provider_region}"
  k8s_version                   = "${var.provider_k8s_version}"
  startup_master_size           = "${data.nks_instance_specs.master-specs.node_size}"
  startup_worker_count          = 2
  startup_worker_size           = "${data.nks_instance_specs.worker-specs.node_size}"
  rbac_enabled                  = true
  dashboard_enabled             = true
  etcd_type                     = "${var.provider_etcd_type}"
  platform                      = "${var.provider_platform}"
  channel                       = "${var.provider_channel}"
  ssh_keyset                    = "${data.nks_keyset.keyset_ssh.id}"
  provider_network_id_requested = "${var.provider_network_id}"
  provider_network_cidr         = "${var.provider_network_cidr}"
  provider_subnet_id_requested  = "${var.provider_subnet_id}"

  lifecycle {
    ignore_changes = [
      "provider_network_cidr"
    ]
  }
}
