output "gke_cluster_primary_admin_service_account_key" {
  value = "${module.gcp_gke_cluster_primary_module.gke_admin_service_account_key}"
}

output "gke_cluster_secondary_admin_service_account_key" {
  value = "${module.gcp_gke_cluster_secondary_module.gke_admin_service_account_key}"
}

output "vault_gcp_auth_account_key" {
  value = "${base64decode(google_service_account_key.vault_gcp_auth_account_key.private_key)}"
}

output "vault_admin_account_key" {
  value = "${base64decode(google_service_account_key.vault_admin_account_key.private_key)}"
}

output "failover_control_account_key" {
  value = "${base64decode(google_service_account_key.failover_control_account_key.private_key)}"
}

output "k8s_state_service_account_key" {
  value = "${module.gcp_gcs_kms_k8s_state_module.gcs_bucket_service_account_key}"
}

output "vault_state_service_account_key" {
  value = "${module.gcp_gcs_kms_vault_state_module.gcs_bucket_service_account_key}"
}




