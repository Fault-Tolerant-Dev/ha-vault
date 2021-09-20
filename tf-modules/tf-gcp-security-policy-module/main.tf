resource "google_compute_security_policy" "vault_policy" {
  name = "vault-policy"

  rule {
    action   = "allow"
    priority = "101"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = [var.vault_src_ips]
      }
    }

    description = "vault src ips"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Default Deny"
  }
}

