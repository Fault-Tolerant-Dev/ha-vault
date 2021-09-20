output "google_compute_network_name" {
  value = google_compute_network.network.name
}

output "google_compute_subnetwork_name" {
  value = google_compute_subnetwork.subnetwork.*.name
}
