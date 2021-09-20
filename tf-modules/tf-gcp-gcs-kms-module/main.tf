resource "random_id" "random_suffix" {
  byte_length = 2
}

locals {
  svc_account_fmt = format("serviceAccount:%s", google_service_account.gcs_bucket_service_account.email)
}

/******************************************
  KMS Configuration
 *****************************************/
resource "google_kms_key_ring" "kms_keyring" {
  name     = "${var.key_ring_name}-${random_id.random_suffix.dec}"
  location = var.kms_location
}

resource "google_kms_crypto_key" "kms_key" {
  name            = "${var.key_name}-${random_id.random_suffix.dec}"
  key_ring        = google_kms_key_ring.kms_keyring.self_link
  rotation_period = "864001s"
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = "false"
  }

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "HSM"
  }
}

/******************************************
  Bucket Configuration
 *****************************************/
resource "google_storage_bucket" "gcs_bucket" {
  name          = "${var.bucket_name}-${random_id.random_suffix.dec}"
  force_destroy = "true"                                              # Flip this to false when done testing
  location      = var.bucket_location
  storage_class = "MULTI_REGIONAL"

  versioning {
    enabled = "true"
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.kms_key.self_link
  }
}

/******************************************
  IAM Configuration
 *****************************************/
data "google_project" "project" {}

resource "google_kms_crypto_key_iam_member" "kms_keyring_endec_membership" {
  crypto_key_id = google_kms_crypto_key.kms_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
}

# Need this over a list
#resource "google_kms_crypto_key_iam_member" "kms_keyring_endec_membership" {
#  crypto_key_id = "${google_kms_crypto_key.kms_key.id}"
#  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
#  member        = "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
#}

resource "google_service_account" "gcs_bucket_service_account" {
  account_id = var.bucket_service_account
}

resource "google_storage_bucket_iam_member" "gcs_bucket_iam_member" {
  bucket = google_storage_bucket.gcs_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.gcs_bucket_service_account.email}"
}

resource "google_service_account_key" "gcs_bucket_service_account_key" {
  service_account_id = google_service_account.gcs_bucket_service_account.name
}
