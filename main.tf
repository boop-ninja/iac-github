variable "owner" {
  type    = string
  default = "mbround18"
}

data "github_repositories" "repositories" {
  query           = "org:${var.owner}"
  include_repo_id = true
}

resource "github_branch_protection" "i" {
  for_each      = { for repo in data.github_repositories.repositories.names : repo => repo }
  pattern       = "main"
  repository_id = "${var.owner}/${each.value}"

  enforce_admins = true

  require_conversation_resolution = true

  allows_force_pushes = false
  allows_deletions    = false
}

output "repositories" {
  value = data.github_repositories.repositories.names
}

