resource "vault_auth_backend" "approle" {
  type                      = "approle"
  default_lease_ttl_seconds = "3600"
}

