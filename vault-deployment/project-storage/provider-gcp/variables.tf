/******************************************
  Project Vars
 *****************************************/
variable "project_id" {
  type = "string"
}

/******************************************
  Bucket Vars
 *****************************************/
variable "gcp_gcs_kms_vault_storage_kms_location" {
  type = "string"
}

variable "gcp_gcs_kms_vault_storage_key_ring_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_storage_key_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_storage_bucket_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_storage_bucket_location" {
  type = "string"
}

variable "gcp_gcs_kms_vault_storage_bucket_service_account" {
  type = "string"
}

/******************************************
  Bucket Vars
 *****************************************/
variable "gcp_kms_vault_seal_location" {
  type = "string"
}

variable "gcp_kms_vault_seal_ring_name" {
  type = "string"
}

variable "gcp_kms_vault_seal_key_name" {
  type = "string"
}

variable "gcp_kms_vault_seal_account_id" {
  type = "string"
}

variable "gcp_kms_vault_seal_display_name" {
  type = "string"
}
