variable "loadbalancer_ip" {
  type = "string"
}

variable "cluster_ip" {
  type = "string"
}

#variable "vault_combined_crt" {
#  type = "string"
#}
#
#variable "vault_key" {
#  type = "string"
#}

variable "vault_image" {
  type = "string"
}

#variable "vault_seal_key" {
#  type = "string"
#}

# Vault Config File Vars

variable "vault_config_lb_ip" {
  type = "string"
}

variable "vault_config_cluster_ip" {
  type = "string"
}

variable "vault_config_storage_bucket_name" {
  type = "string"
}

variable "vault_config_locks_bucket_name" {
  type = "string"
}

variable "vault_config_gcpkms_project_id" {
  type = "string"
}

variable "vault_config_gcpkms_project_region" {
  type = "string"
}

variable "vault_config_gcpkms_keyring" {
  type = "string"
}

variable "vault_config_gcpkms_key" {
  type = "string"
}

variable "vault_config_enable_ui" {
  type    = "string"
  default = "false"
}

variable "vault_config_log_level" {
  type    = "string"
  default = "info"
}

variable "vault_secrets_seal_key" {
  type = "string"
}

variable "vault_secrets_tls_crt" {
  type = "string"
}

variable "vault_secrets_tls_key" {
  type = "string"
}
