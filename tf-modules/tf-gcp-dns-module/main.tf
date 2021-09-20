resource "google_dns_managed_zone" "managed_zone_vault" {
  name     = "vault-zone"
  dns_name = var.vault_domain
}

resource "google_dns_record_set" "record_set_primary_vault" {
  name = "vault-primary.${google_dns_managed_zone.managed_zone_vault.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.managed_zone_vault.name

  rrdatas = [google_compute_instance.frontend.network_interface[0].access_config[0].nat_ip]
}