variable "cluster_name" {
  description = "name of the cluster"
  type = string
}

variable "db_remote_state_bucket" {
  description = "s3 bucket name for the db's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "path for the db's remote state in s3"
  type = string
}
