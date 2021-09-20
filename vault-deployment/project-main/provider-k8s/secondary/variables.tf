/******************************************
 Vault Vars
 *****************************************/

variable "k8s_vault_loadbalancer_ip" {
  type = "string"
}

variable "k8s_vault_cluster_ip" {
  type = "string"
}

variable "k8s_vault_tls_combined_crt" {
  type = "string"
}

variable "k8s_vault_tls_key" {
  type = "string"
}

variable "k8s_vault_image" {
  type = "string"
}

variable "k8s_vault_seal_key" {
  type = "string"
}

variable  "k8s_vault_storage_bucket_name" {
  type = "string"
}

variable  "k8s_vault_locks_bucket" {
  type = "string"
}

variable  "k8s_vault_gcpkms_project_id" {
  type = "string"
}

variable  "k8s_vault_gcpkms_project_region" {
  type = "string"
}

variable  "k8s_vault_gcpkms_keyring" {
  type = "string"
}

variable  "k8s_vault_gcpkms_key" {
  type = "string"
}

variable  "k8s_vault_enable_ui" {
  type = "string"
}

variable  "k8s_vault_log_level" {
  type = "string"
}


