variable "owner" {
  type    = string
  default = "mbround18"
}

variable "ignore_list" {
  type = list(string)
  default = [
    "wikijs-content"
  ]
}

data "github_repositories" "repositories" {
  query           = "org:${var.owner}"
  include_repo_id = true
}

data "github_repository" "repository" {
  for_each = {
    for key, repo in data.github_repositories.repositories.names : repo => repo
    if key != "" && !contains(var.ignore_list, key)
  }
  full_name = each.value
}

resource "github_branch_protection" "i" {
  for_each = {
    for repo in data.github_repository.repository.* : repo => repo.full_name
    if !repo.archived
  }
  pattern       = "main"
  repository_id = each.value

  enforce_admins = true

  require_conversation_resolution = true

  allows_force_pushes = false
  allows_deletions    = false
}

output "repositories" {
  value = data.github_repositories.repositories.names
}

