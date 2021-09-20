/******************************************
  GKE Cluster Configuration
 *****************************************/
output "gke_admin_service_account_key" {
  value = base64decode(google_service_account_key.gke_admin_service_account_key.private_key)
}

output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}
