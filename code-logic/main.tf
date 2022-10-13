provider "aws" {
  region = "us-east-1"
}

variable "users" {
  type    = list(string)
  default = ["mrri", "mar0ne", "our"]
}

# resource "aws_iam_user" "example" {
#     for_each = toset(var.users)
#     name = each.value
# }

output "all_arns" {
  value       = values(aws_iam_user.example)[*].arn
  description = "The ARN of all users"
}

variable "custom_tags" {
  type = map(string)
  default = {
    env = "test"
    user = "moha"
    goal = "testing"
  }
}
