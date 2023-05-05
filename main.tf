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
  full_name = "${var.owner}/${each.value}"
}

locals {
  filtered_repos = {
    for repo in data.github_repository.repository.* : repo => repo.archived ? null : repo.full_name
  }
}

resource "github_branch_protection" "i" {
  for_each      = local.filtered_repos
  pattern       = "main"
  repository_id = each.value

  enforce_admins = true

  require_conversation_resolution = true

  allows_force_pushes = false
  allows_deletions    = false
}

variable "docker_token" {
  default = ""
}

locals {
  secrets = {
    DOCKER_TOKEN = var.docker_token
    GHCR_TOKEN   = var.gh_token
    GH_TOKEN     = var.gh_token
    AUTO_TOKEN   = var.gh_token
  }
}

resource "github_actions_secret" "i" {
  for_each = {
    for repo in local.filtered_repos : repo => {
      for key, value in local.secrets : key => { key = key, value = value, repo = repo["full_name"] }
    }
  }

  repository      = each.value["repo"]
  secret_name     = each.value["key"]
  plaintext_value = each.value["value"]
}

output "repositories" {
  value = data.github_repositories.repositories.names
}

