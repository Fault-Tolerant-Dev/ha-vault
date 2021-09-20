/******************************************
  Bucket Configurations
 *****************************************/
module "gcp_gcs_kms_vault_storage_module" {
  source                 = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-gcs-kms-module.git"
  kms_location           = "${var.gcp_gcs_kms_vault_storage_kms_location}"
  key_ring_name          = "${var.gcp_gcs_kms_vault_storage_key_ring_name}"
  key_name               = "${var.gcp_gcs_kms_vault_storage_key_name}"
  bucket_name            = "${var.gcp_gcs_kms_vault_storage_bucket_name}"
  bucket_location        = "${var.gcp_gcs_kms_vault_storage_bucket_location}"
  bucket_service_account = "${var.gcp_gcs_kms_vault_storage_bucket_service_account}"
}

/******************************************
  KMS Configurations
 *****************************************/
module "gcp_gcs_kms_vault_seal_module" {
  source        = "git::ssh://git@github.ebay.com/StubHub-Vault/tf-gcp-kms-module.git"
  kms_location  = "${var.gcp_kms_vault_seal_location}"
  key_ring_name = "${var.gcp_kms_vault_seal_ring_name}"
  key_name      = "${var.gcp_kms_vault_seal_key_name}"
  account_id    = "${var.gcp_kms_vault_seal_account_id}"
  display_name  = "${var.gcp_kms_vault_seal_display_name}"
}
