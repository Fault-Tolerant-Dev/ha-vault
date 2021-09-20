/****************************************
  Service Account Creation
*****************************************/
resource "google_service_account" "gke_node_pool_service_account" {
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_project_iam_member" "gke_node_pool_service_account_metric_writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke_node_pool_service_account.email}"
}

resource "google_project_iam_member" "gke_node_pool_service_account_logging_writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.gke_node_pool_service_account.email}"
}

/******************************************
  GKE Node Configuration
 *****************************************/
resource "google_container_node_pool" "gke_node_pool" {
  name       = var.node_pool_name
  location   = var.region
  cluster    = var.gke_cluster_name
  node_count = "1"

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible = false

    service_account = google_service_account.gke_node_pool_service_account.email
    machine_type    = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloudkms",
      "https://www.googleapis.com/auth/devstorage.read_write",
    ]

    labels {
      type = var.node_pool_name
    }

    tags = [var.node_pool_name]
  }
}
