resource "random_id" "random_suffix" {
  byte_length = 2
}

/******************************************
  Static IP Config
 *****************************************/
resource "google_compute_address" "address" {
  name   = var.address_static_name
  region = var.region
}

/******************************************
  Router Configuration
 *****************************************/
resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = var.router_network_name

  bgp {
    asn = var.router_asn
  }
}

/******************************************
  Nat Configuration
 *****************************************/
resource "google_compute_router_nat" "main" {
  region                             = var.region
  name                               = google_compute_router.router.name
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.address.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }

  depends_on = [
    "google_compute_address.address",
    "google_compute_router.router",
  ]
}
