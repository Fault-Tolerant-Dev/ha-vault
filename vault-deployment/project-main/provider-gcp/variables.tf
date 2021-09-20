/******************************************
  Project Vars
 *****************************************/
variable "project_id" {
  type = "string"
}

variable "region_primary" {
  type = "string"
}

variable "region_secondary" {
  type = "string"
}

/******************************************
  Network Vars
 *****************************************/

variable "gke_network_name" {
  type = "string"
}

variable "gke_network_primary_subnets" {
  type = "list"
}

variable "gke_network_secondary_subnets" {
  type = "map"
}

variable "vault_consumer_nets" {
  type  = "list"
}


/******************************************
  Cloud Nat Vars
 *****************************************/
variable "static_primary_name" {
  type = "string"
}

variable "router_primary_name" {
  type = "string"
}

variable "router_primary_asn" {
  type = "string"
}

variable "static_secondary_name" {
  type = "string"
}

variable "router_secondary_name" {
  type = "string"
}

variable "router_secondary_asn" {
  type = "string"
}

/******************************************
  Cluster Vars
 *****************************************/
variable "gcp_gke_cluster_primary_master_auth_cidr" {
  type = "string"
}

variable "gcp_gke_cluster_primary_master_auth_cidr_name" {
  type = "string"
}

variable "gcp_gke_cluster_primary_master_private_cidr" {
  type = "string"
}

variable "gcp_gke_cluster_primary_name" {
  type = "string"
}


variable "gcp_gke_cluster_primary_subnetwork_name" {
  type = "string"
}

variable "gcp_gke_cluster_primary_pod_range" {
  type = "string"
}

variable "gcp_gke_cluster_primary_svc_range" {
  type = "string"
}

###############

variable "gcp_gke_cluster_secondary_master_auth_cidr" {
  type = "string"
}

variable "gcp_gke_cluster_secondary_master_auth_cidr_name" {
  type = "string"
}

variable "gcp_gke_cluster_secondary_master_private_cidr" {
  type = "string"
}

variable "gcp_gke_cluster_secondary_name" {
  type = "string"
}



variable "gcp_gke_cluster_secondary_subnetwork_name" {
  type = "string"
}

variable "gcp_gke_cluster_secondary_pod_range" {
  type = "string"
}

variable "gcp_gke_cluster_secondary_svc_range" {
  type = "string"
}

/******************************************
  GKE Node Vars
 *****************************************/
variable "gcp_gke_node_pool_primary_name" {
  type = "string"
}

variable "gcp_gke_node_pool_primary_machine_type" {
  type = "string"
}

variable "gcp_gke_node_pool_primary_account_id" {
  type = "string"
}

variable "gcp_gke_node_pool_primary_display_name" {
  type = "string"
}

#############
variable "gcp_gke_node_pool_secondary_name" {
  type = "string"
}

variable "gcp_gke_node_pool_secondary_machine_type" {
  type = "string"
}

variable "gcp_gke_node_pool_secondary_account_id" {
  type = "string"
}

variable "gcp_gke_node_pool_secondary_display_name" {
  type = "string"
}

/******************************************
  Bucket Vars
 *****************************************/
variable "gcp_gcs_kms_k8s_state_kms_location" {
  type = "string"
}

variable "gcp_gcs_kms_k8s_state_key_ring_name" {
  type = "string"
}

variable "gcp_gcs_kms_k8s_state_key_name" {
  type = "string"
}

variable "gcp_gcs_kms_k8s_state_bucket_name" {
  type = "string"
}

variable "gcp_gcs_kms_k8s_state_bucket_location" {
  type = "string"
}

variable "gcp_gcs_kms_k8s_state_bucket_service_account" {
  type = "string"
}

variable "gcp_gcs_kms_vault_state_kms_location" {
  type = "string"
}

variable "gcp_gcs_kms_vault_state_key_ring_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_state_key_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_state_bucket_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_state_bucket_location" {
  type = "string"
}

variable "gcp_gcs_kms_vault_state_bucket_service_account" {
  type = "string"
}

variable "gcp_gcs_kms_vault_locks_kms_location" {
  type = "string"
}

variable "gcp_gcs_kms_vault_locks_key_ring_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_locks_key_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_locks_bucket_name" {
  type = "string"
}

variable "gcp_gcs_kms_vault_locks_bucket_location" {
  type = "string"
}

variable "gcp_gcs_kms_vault_locks_bucket_service_account" {
  type = "string"
}


