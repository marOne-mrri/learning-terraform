provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "terraform_state_kms_key" {
  description             = "KMS key for terraform state"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-managment-bucket"
  lifecycle {
    prevent_destroy = true
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption_config" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-up-and-running-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-managment-bucket"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-state-locks"
    encrypt        = true
  }
}
