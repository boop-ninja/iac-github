variable "gh_token" {
  type = string
}

provider "github" {
  token = var.gh_token # or `GITHUB_TOKEN`
}