include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

  region      = local.region_vars.locals.region
  environment = local.environment_vars.locals.environment
}

terraform {
  source = "../../../../../modules/security-group"
}

dependency "vpc" {
  config_path = "../../shared/vpc"

  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }

  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  security_groups = {
    "${local.environment}-k8s" = {
      description = "Security group for K8s cluster"
      ingress_rules = [
        {
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          // TODO: strict this ip into vpc ip
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "K8s API server"
          from_port   = 6443
          to_port     = 6443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "NodePort Services"
          from_port   = 30000
          to_port     = 32767
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "Internal cluster communication"
          from_port   = 0
          to_port     = 65535
          protocol    = "tcp"
          self        = true
        }
      ]
      tags = { Role = "k8s" }
    }

    # Example: Add database security group in the future
    # "${local.environment}-db-sg" = {
    #   description = "Security group for database instances"
    #   ingress_rules = [
    #     {
    #       description = "PostgreSQL from K8s"
    #       from_port   = 5432
    #       to_port     = 5432
    #       protocol    = "tcp"
    #       cidr_blocks = ["10.0.0.0/16"]
    #     }
    #   ]
    #   tags = { Role = "database" }
    # }
  }
}
