output "gcs_bucket_name" {
  value = google_storage_bucket.gcs_bucket.name
}

output "gcs_bucket_service_account" {
  value = google_service_account.gcs_bucket_service_account.email
}

output "gcs_bucket_service_account_key" {
  value = base64decode(google_service_account_key.gcs_bucket_service_account_key.private_key)
}
