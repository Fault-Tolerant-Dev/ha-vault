/******************************************
	VPC Network configuration
 *****************************************/
resource "google_compute_network" "network" {
  name                            = var.network_name
  auto_create_subnetworks         = "false"
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_defaults
}

/******************************************
	Subnet configuration
 *****************************************/
resource "google_compute_subnetwork" "subnetwork" {
  count = length(var.primary_subnets)

  provider                 = "google-beta"
  name                     = lookup(var.primary_subnets[count.index], "subnet_name")
  ip_cidr_range            = lookup(var.primary_subnets[count.index], "subnet_ip")
  secondary_ip_range       = var.secondary_subnets[lookup(var.primary_subnets[count.index], "subnet_name")]
  region                   = lookup(var.primary_subnets[count.index], "subnet_region")
  private_ip_google_access = lookup(var.primary_subnets[count.index], "subnet_private_access", "true")
  enable_flow_logs         = lookup(var.primary_subnets[count.index], "subnet_flowlogs", "true")
  network                  = google_compute_network.network.name
}
