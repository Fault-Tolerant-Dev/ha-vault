# Vault config
disable_cluster = "false"
disable_mlock = "true"
api_addr = "https://${vault_lb_ip}:8200"
cluster_addr = "https://${vault_cluster_ip}:8201"
#default_lease_ttl =
#max_lease_ttl =


listener "tcp" {
  tls_disable = "false"
  tls_cert_file = "/vault/tls/vault.crt"
  tls_key_file  = "/vault/tls/vault.key"
  tls_disable_client_certs = "true"
  tls_min_version = "tls12"
  tls_cipher_suites = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
  tls_prefer_server_cipher_suites = "true"
  address = "[::]:8200"
  cluster_address = "[::]:8201"
}


# Vault Storage Bucket
storage "gcs" {
  bucket = "${vault_storage_bucket}"
}

# Vault Locking Bucket
ha_storage "gcs" {
  bucket = "${vault_locks_bucket}"
  ha_enabled = "true"
}

seal "gcpckms" {
   project     = "${vault_gcpckms_project_id}"
   region      = "${vault_gcpckms_region}"
   key_ring    = "${vault_gcpckms_keyring}"
   crypto_key  = "${vault_gcpckms_key}"
   credentials = "/vault/seal/vault_seal.key.json"
}

# Tooling
ui = "${enable_vault_ui}"
log_level = "${vault_log_level}"
