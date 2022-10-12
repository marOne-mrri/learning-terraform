provider "aws" {
  region = "us-esat-1"
}

module "webserver_cluster" {
  source = "../"
  cluster_name = "my-lb-sec-grp"
  db_remote_state_bucket = "terraform-up-and-running-state-managment-bucket"
  db_remote_state_key = "stage/data-store/mysql/terraform.tfstate"
}
