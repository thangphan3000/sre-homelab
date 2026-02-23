variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "security_groups" {
  description = "Map of security groups to create"
  type = map(object({
    description = optional(string, "Managed by Terraform")
    ingress_rules = optional(list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      self        = optional(bool)
    })), [])
    egress_rules = optional(list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
      })), [{
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }])
  }))
  default = {}
}
