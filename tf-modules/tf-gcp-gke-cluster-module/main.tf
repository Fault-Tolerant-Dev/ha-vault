resource "random_id" "random_suffix" {
  byte_length = 2
}

/******************************************
  KMS Configuration
 *****************************************/
resource "google_kms_key_ring" "kms_etcd_keyring" {
  name     = "kms-etcd-keyring-${random_id.random_suffix.dec}"
  location = var.kms_etc_location
}

resource "google_kms_crypto_key" "kms_etcd_keys" {
  name            = "kms-etcd-keys-${random_id.random_suffix.dec}"
  key_ring        = google_kms_key_ring.kms_etcd_keyring.self_link
  rotation_period = "864001s"
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = false
  }

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "HSM"
  }
}

data "google_project" "project" {}

resource "google_kms_crypto_key_iam_member" "kms_etcd_keyring_endec_membership" {
  crypto_key_id = google_kms_crypto_key.kms_etcd_keys.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

/******************************************
  GKE Cluster Configuration
 *****************************************/
resource "google_container_cluster" "gke_cluster" {
  provider           = "google-beta"
  name               = var.cluster_name
  location           = var.region
  network            = var.network_name
  subnetwork         = var.subnetwork_name
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.kms_etcd_keys.id
  }
  enable_shielded_nodes = true

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_secondary_range
    services_secondary_range_name = var.svc_secondary_range
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.master_auth_cidr
      display_name = var.master_auth_cidr_name
    }
  }

  private_cluster_config {
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
    master_ipv4_cidr_block  = var.master_private_cidr
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = "true"
    }

    http_load_balancing {
      disabled = "false"
    }

    kubernetes_dashboard {
      disabled = true
    }

    network_policy_config {
      disabled = "false"
    }

    istio_config {
      disabled = "true"
      auth     = "AUTH_MUTUAL_TLS"
    }
  }

  pod_security_policy_config {
    enabled = "true"
  }

  master_auth {
    password = ""
    username = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.daily_maintenance_start_time
    }
  }
}


/****************************************
  Service Account Creation
*****************************************/
resource "google_service_account" "gke_admin_service_account" {
  account_id   = "${var.cluster_name}-gke-admin"
  display_name = "${var.cluster_name} gke admin"
}

resource "google_service_account_key" "gke_admin_service_account_key" {
  service_account_id = google_service_account.gke_admin_service_account.name
}

/******************************************
  IAM Configuration
 *****************************************/
resource "google_project_iam_member" "gke_admin_membership" {
  role          = "roles/container.admin"
  member        = "serviceAccount:${google_service_account.gke_admin_service_account.email}"
}



