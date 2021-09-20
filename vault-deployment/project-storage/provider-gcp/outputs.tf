output "kms_service_account_key" {
  value = "${module.gcp_gcs_kms_vault_seal_module.kms_service_account_key}"
}