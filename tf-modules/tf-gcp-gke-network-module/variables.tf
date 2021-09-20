variable "network_name" {
  description = "The name of the network being created"
}

variable "delete_defaults" {
  description = "The name of the network being created"
  default     = false
}

variable "primary_subnets" {
  type        = "list"
  description = "The list of primary subnets being created"
}

variable "secondary_subnets" {
  type        = "map"
  description = "The list of secondary subnets being created"
}

variable "routing_mode" {
  description = "The routing mode of the network. Default GLOBAL"
  default     = "GLOBAL"
}
