provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "my_db" {
  allocated_storage   = 10
  db_name             = "mydb"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  username            = "admin"
  password            = var.db_password
  skip_final_snapshot = true
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-managment-bucket"
    key            = "stage/data-store/mysql/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-state-locks"
    encrypt        = true
  }
}
