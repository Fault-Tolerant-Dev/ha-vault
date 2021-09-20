/******************************************
  KMS Outputs
 *****************************************/

output "kms_service_account_key" {
  value = base64decode(google_service_account_key.kms_service_account_key.private_key)
}
