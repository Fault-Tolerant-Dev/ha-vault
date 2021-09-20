/******************************************
  AuditD Configurations
 *****************************************/
module "k8s_auditd_module" {
  source = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-k8s-auditd-module.git"
}

/******************************************
  Vault Configurations
 *****************************************/
module "k8s_vault_module" {
  source = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-k8s-vault-module.git"

  # Vault Service Config
  loadbalancer_ip = "${var.k8s_vault_loadbalancer_ip}"
  cluster_ip      = "${var.k8s_vault_cluster_ip}"
  vault_image     = "${var.k8s_vault_image}"

  # Vault TLS Config
  vault_secrets_tls_crt = "${var.k8s_vault_tls_combined_crt}"
  vault_secrets_tls_key = "${var.k8s_vault_tls_key}"

  # Vault Seal Key
  vault_secrets_seal_key = "${var.k8s_vault_seal_key}"

  # Vault Config File Vars
  vault_config_lb_ip                 = "${var.k8s_vault_loadbalancer_ip}"
  vault_config_cluster_ip            = "${var.k8s_vault_cluster_ip}"
  vault_config_storage_bucket_name   = "${var.k8s_vault_storage_bucket_name}"
  vault_config_locks_bucket_name     = "${var.k8s_vault_locks_bucket}"
  vault_config_gcpkms_project_id     = "${var.k8s_vault_gcpkms_project_id}"
  vault_config_gcpkms_project_region = "${var.k8s_vault_gcpkms_project_region}"
  vault_config_gcpkms_keyring        = "${var.k8s_vault_gcpkms_keyring}"
  vault_config_gcpkms_key            = "${var.k8s_vault_gcpkms_key}"
  vault_config_enable_ui             = "${var.k8s_vault_enable_ui}"
  vault_config_log_level             = "${var.k8s_vault_log_level}"
}
