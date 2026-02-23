locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project_vars     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  aws_account_id = local.account_vars.locals.id
  aws_profile    = local.account_vars.locals.profile
  aws_region     = local.region_vars.locals.region
  environment    = local.environment_vars.locals.environment
  project        = local.project_vars.locals.project
  team_owner     = local.account_vars.locals.team_owner
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "6.27.0"
      }
    }
  }

  provider "aws" {
    region  = "${local.aws_region}"
    profile = "${local.aws_profile}"

    default_tags {
      tags = {
        Environment = "${local.environment}"
        ManagedBy   = "terraform"
        Project     = "${local.project}"
        TeamOwner   = "${local.team_owner}"
      }
    }
  }
EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  terraform {
    backend "s3" {
      bucket       = "music-homelab"
      encrypt      = true
      key          = "${path_relative_to_include()}/terraform.tfstate"
      profile      = "${local.aws_profile}"
      region       = "${local.aws_region}"
      use_lockfile = true
    }
  }
EOF
}