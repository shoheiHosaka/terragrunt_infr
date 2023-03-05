remote_state {
  backend = "s3"
  config = {
    bucket  = "shohei-terraform-tfstate"
    key     = "${path_relative_to_include()}.tfstate"
    region  = "ap-northeast-1"
    encrypt = false
  }
}

locals {
  accountid     = get_aws_account_id()
  github_repos  = [
    "repo:shoheiHosaka/terragrunt_infra:ref:refs/heads/main",
    "repo:shoheiHosaka/terragrunt_infra:ref:refs/heads/*",
    ]
}

inputs = {
  accountid     = local.accountid
  github_repos  = local.github_repos  
}
