provider "aws" {
  region = "us-east-2"

  # avoid accidentally modifying the wrong AWS account
  allowed_account_ids = ["224588347132"]
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}
