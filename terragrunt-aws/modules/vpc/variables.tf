variable "azs" {
  description = "List of availability zones names or IDs in the region"
  type        = list(string)
  nullable    = false
}

variable "cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.cidr))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "environment" {
  description = "Environment name (development1–development12, staging, pre-production, production)"
  type        = string
  nullable    = false

  validation {
    condition = (
      can(regex("^development(1[0-2]|[1-9])$", var.environment)) ||
      var.environment == "staging" ||
      var.environment == "pre-production" ||
      var.environment == "production"
    )
    error_message = "Environment must be one of: development1–development12, staging, pre-production, production."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "trusted_subnets" {
  description = "List of trusted subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "is_enable_nat" {
  description = "Enable NAT GW"
  type        = bool
  default     = true
}
