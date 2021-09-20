/******************************************
  KMS Variables
 *****************************************/
variable "kms_location" {
  type = "string"
}

variable "key_ring_name" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

/******************************************
  Bucket Variables
 *****************************************/
variable "bucket_name" {
  type = "string"
}

variable "bucket_location" {
  type = "string"
}

/******************************************
  IAM Variables
 *****************************************/

variable "bucket_service_account" {
  type = "string"
}
