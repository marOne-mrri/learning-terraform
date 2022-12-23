provider "github" {
  token = "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"
}

data "github_repository" "example" {
  name = "learning-terraform"
}

resource "github_repository_file" "foo" {
  repository          = data.github_repository.example.name
  branch              = "main"
  file                = "text.txt"
  content             = "**/*.gitignore"
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}

output "name" {
    value = data.github_repository.example.name
}
