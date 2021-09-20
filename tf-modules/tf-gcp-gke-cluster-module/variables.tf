/******************************************
  KMS Variables
 *****************************************/
variable "kms_etc_location" {
  type = "string"
}

/******************************************
  GKE Cluster Variables
 *****************************************/
variable "region" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "network_name" {
  type = "string"
}

variable "subnetwork_name" {
  type = "string"
}

variable "master_auth_cidr" {
  type = "string"
}

variable "master_auth_cidr_name" {
  type = "string"
}

variable "master_private_cidr" {
  type = "string"
}

variable "pod_secondary_range" {
  type = "string"
}

variable "svc_secondary_range" {
  type = "string"
}

variable "daily_maintenance_start_time" {
  type    = "string"
  default = "03:00"
}
