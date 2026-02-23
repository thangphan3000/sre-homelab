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
  source = "../../../../../modules/vpc"
}

inputs = {
  azs                 = ["${local.region}a", "${local.region}b"]
  cidr                = "10.0.0.0/16"
  environment         = local.environment
  is_enable_nat       = false
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  trusted_subnets     = ["10.0.5.0/24", "10.0.6.0/24"]
  private_subnet_tags = {}
  public_subnet_tags  = {}
}
