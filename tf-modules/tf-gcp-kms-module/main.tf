resource "random_id" "random_suffix" {
  byte_length = 2
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
    prevent_destroy = true
  }

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "HSM"
  }
}

/****************************************
  Service Account Creation
*****************************************/
resource "google_service_account" "kms_service_account" {
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_service_account_key" "kms_service_account_key" {
  service_account_id = google_service_account.kms_service_account.name
}

/******************************************
  IAM Configuration
 *****************************************/
resource "google_kms_crypto_key_iam_member" "kms_keyring_endec_membership" {
  crypto_key_id = google_kms_crypto_key.kms_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.kms_service_account.email}"
}
