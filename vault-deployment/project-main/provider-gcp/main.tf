/******************************************
  DNS Configurations
 *****************************************/
# Make this a module
# Validate DNSSEC again
resource "google_dns_managed_zone" "managed_zone_vault" {
  name     = "vault-zone"
  dns_name = "evilmachine.net."
}

resource "google_dns_record_set" "record_set_primary_vault" {
  name = "vault-primary.${google_dns_managed_zone.managed_zone_vault.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.managed_zone_vault.name}"

  rrdatas = ["${google_compute_address.vault_static_primary.address}"]
}

resource "google_dns_record_set" "record_set_secondary_vault" {
  name = "vault-secondary.${google_dns_managed_zone.managed_zone_vault.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.managed_zone_vault.name}"

  rrdatas = ["${google_compute_address.vault_static_secondary.address}"]
}

resource "google_dns_record_set" "record_set_vault" {
  name = "vault.${google_dns_managed_zone.managed_zone_vault.dns_name}"
  type = "CNAME"
  ttl  = 60

  managed_zone = "${google_dns_managed_zone.managed_zone_vault.name}"

  rrdatas = ["${google_dns_record_set.record_set_primary_vault.name}"]
}

/****************************************
  Failover Control Account
*****************************************/
resource "google_service_account" "failover_control_account" {
  account_id   = "failover-control-account"
  display_name = "failover-control-account"
}

# For testing - Delete with use of CloudFunction
resource "google_service_account_key" "failover_control_account_key" {
  service_account_id = "${google_service_account.failover_control_account.name}"
}

resource "google_project_iam_member" "failover_control_account_membership_dns" {
  role   = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.failover_control_account.email}"
}

resource "google_project_iam_member" "failover_control_account_membership_gke" {
  role          = "roles/container.developer"
  member        = "serviceAccount:${google_service_account.failover_control_account.email}"
}


resource "google_storage_bucket_iam_member" "failover_control_account_iam_member" {
  bucket     = "${module.gcp_gcs_kms_vault_locks_module.gcs_bucket_name}"
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.failover_control_account.email}"
  depends_on = ["module.gcp_gcs_kms_vault_locks_module"]
}

/****************************************
  Vault GCP IAM Auth Accounts
*****************************************/
# Vault Service account to enable GCP IAM as Auth provider for Vault
resource "google_service_account" "vault_gcp_auth_account" {
  account_id   = "vault-gcp-auth-account"
  display_name = "vault-gcp-auth-account"
}

resource "google_service_account_key" "vault_gcp_auth_account_key" {
  service_account_id = "${google_service_account.vault_gcp_auth_account.name}"
}

resource "google_project_iam_member" "vault_gcp_auth_account_membership" {
  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "serviceAccount:${google_service_account.vault_gcp_auth_account.email}"
}

# Vault account you will use going forward
resource "google_service_account" "vault_admin_account" {
  account_id   = "vault-admin-account"
  display_name = "vault-admin-account"
}

resource "google_service_account_key" "vault_admin_account_key" {
  service_account_id = "${google_service_account.vault_admin_account.name}"
}

resource "google_project_iam_member" "vault_admin_accoun_membership" {
  role   = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${google_service_account.vault_admin_account.email}"
}

/******************************************
  Network Configurations
 *****************************************/
module "gcp_gke_network_module" {
  source            = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gke-network-module.git"
  network_name      = "${var.gke_network_name}"
  primary_subnets   = "${var.gke_network_primary_subnets}"
  secondary_subnets = "${var.gke_network_secondary_subnets}"
}

module "gcp_gke_cloudnat_module_primary" {
  source              = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-cloudnat-module.git"
  region              = "${var.region_primary}"
  address_static_name = "${var.static_primary_name}"
  router_name         = "${var.router_primary_name}"
  router_network_name = "${module.gcp_gke_network_module.google_compute_network_name}"
  router_asn          = "${var.router_primary_asn}"
}

module "gcp_gke_cloudnat_module_secondary" {
  source              = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-cloudnat-module.git"
  region              = "${var.region_secondary}"
  address_static_name = "${var.static_secondary_name}"
  router_name         = "${var.router_secondary_name}"
  router_network_name = "${module.gcp_gke_network_module.google_compute_network_name}"
  router_asn          = "${var.router_secondary_asn}"
}

resource "google_compute_address" "vault_static_primary" {
  name   = "vault-static-primary"
  region = "${var.region_primary}"
}

resource "google_compute_address" "vault_static_secondary" {
  name   = "vault-static-secondary"
  region = "${var.region_secondary}"
}

module "gcp_security_policy_module" {
  source        = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-security-policy-module.git"
  vault_src_ips = "${var.vault_consumer_nets}"
}

/******************************************
  GKE Cluster Configurations
 *****************************************/
module "gcp_gke_cluster_primary_module" {
  source                = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gke-cluster-module.git"
  region                = "${var.region_primary}"
  kms_etc_location      = "${var.region_primary}"
  cluster_name          = "${var.gcp_gke_cluster_primary_name}"
  network_name          = "${module.gcp_gke_network_module.google_compute_network_name}"
  subnetwork_name       = "primary"
  pod_secondary_range   = "${var.gcp_gke_cluster_primary_pod_range}"
  svc_secondary_range   = "${var.gcp_gke_cluster_primary_svc_range}"
  master_auth_cidr      = "${var.gcp_gke_cluster_primary_master_auth_cidr}"
  master_auth_cidr_name = "${var.gcp_gke_cluster_primary_master_auth_cidr_name}"
  master_private_cidr   = "${var.gcp_gke_cluster_primary_master_private_cidr}"
}

module "gcp_gke_cluster_secondary_module" {
  source                = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gke-cluster-module.git"
  region                = "${var.region_secondary}"
  kms_etc_location      = "${var.region_secondary}"
  cluster_name          = "${var.gcp_gke_cluster_secondary_name}"
  network_name          = "${module.gcp_gke_network_module.google_compute_network_name}"
  subnetwork_name       = "secondary"
  pod_secondary_range   = "${var.gcp_gke_cluster_secondary_pod_range}"
  svc_secondary_range   = "${var.gcp_gke_cluster_secondary_svc_range}"
  master_auth_cidr      = "${var.gcp_gke_cluster_secondary_master_auth_cidr}"
  master_auth_cidr_name = "${var.gcp_gke_cluster_secondary_master_auth_cidr_name}"
  master_private_cidr   = "${var.gcp_gke_cluster_secondary_master_private_cidr}"
}

/******************************************
  GKE Node Configurations
 *****************************************/
module "gcp_gcp_gke_node_primary_module" {
  source           = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gke-node-module.git"
  region           = "${var.region_primary}"
  node_pool_name   = "${var.gcp_gke_node_pool_primary_name}"
  gke_cluster_name = "${module.gcp_gke_cluster_primary_module.gke_cluster_name}"
  machine_type     = "${var.gcp_gke_node_pool_primary_machine_type}"
  account_id       = "${var.gcp_gke_node_pool_primary_account_id}"
  display_name     = "${var.gcp_gke_node_pool_primary_display_name}"
}

module "gcp_gcp_gke_node_secondary_module" {
  source           = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gke-node-module.git"
  region           = "${var.region_secondary}"
  node_pool_name   = "${var.gcp_gke_node_pool_secondary_name}"
  gke_cluster_name = "${module.gcp_gke_cluster_secondary_module.gke_cluster_name}"
  machine_type     = "${var.gcp_gke_node_pool_secondary_machine_type}"
  account_id       = "${var.gcp_gke_node_pool_secondary_account_id}"
  display_name     = "${var.gcp_gke_node_pool_secondary_display_name}"
}

/******************************************
  Bucket Configurations
 *****************************************/
module "gcp_gcs_kms_k8s_state_module" {
  source                 = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gcs-kms-module.git"
  kms_location           = "${var.gcp_gcs_kms_k8s_state_kms_location}"
  key_ring_name          = "${var.gcp_gcs_kms_k8s_state_key_ring_name}"
  key_name               = "${var.gcp_gcs_kms_k8s_state_key_name}"
  bucket_name            = "${var.gcp_gcs_kms_k8s_state_bucket_name}"
  bucket_location        = "${var.gcp_gcs_kms_k8s_state_bucket_location}"
  bucket_service_account = "${var.gcp_gcs_kms_k8s_state_bucket_service_account}"
}

# Wrong Spot for this idiot :)
module "gcp_gcs_kms_vault_state_module" {
  source                 = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gcs-kms-module.git"
  kms_location           = "${var.gcp_gcs_kms_vault_state_kms_location}"
  key_ring_name          = "${var.gcp_gcs_kms_vault_state_key_ring_name}"
  key_name               = "${var.gcp_gcs_kms_vault_state_key_name}"
  bucket_name            = "${var.gcp_gcs_kms_vault_state_bucket_name}"
  bucket_location        = "${var.gcp_gcs_kms_vault_state_bucket_location}"
  bucket_service_account = "${var.gcp_gcs_kms_vault_state_bucket_service_account}"
}

module "gcp_gcs_kms_vault_locks_module" {
  source                 = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gcs-kms-module.git"
  kms_location           = "${var.gcp_gcs_kms_vault_locks_kms_location}"
  key_ring_name          = "${var.gcp_gcs_kms_vault_locks_key_ring_name}"
  key_name               = "${var.gcp_gcs_kms_vault_locks_key_name}"
  bucket_name            = "${var.gcp_gcs_kms_vault_locks_bucket_name}"
  bucket_location        = "${var.gcp_gcs_kms_vault_locks_bucket_location}"
  bucket_service_account = "${var.gcp_gcs_kms_vault_locks_bucket_service_account}"
}

# add feature to module to allow a list thats also empty
resource "google_storage_bucket_iam_member" "primary_node_gcs_bucket_iam_member" {
  bucket     = "${module.gcp_gcs_kms_vault_locks_module.gcs_bucket_name}"
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${module.gcp_gcp_gke_node_primary_module.gke_node_pool_service_account}"
  depends_on = ["module.gcp_gcp_gke_node_primary_module", "module.gcp_gcs_kms_vault_locks_module"]
}

resource "google_storage_bucket_iam_member" "secondary_node_gcs_bucket_iam_member" {
  bucket     = "${module.gcp_gcs_kms_vault_locks_module.gcs_bucket_name}"
  role       = "roles/storage.objectAdmin"
  member     = "serviceAccount:${module.gcp_gcp_gke_node_secondary_module.gke_node_pool_service_account}"
  depends_on = ["module.gcp_gcp_gke_node_secondary_module", "module.gcp_gcs_kms_vault_locks_module"]
}
