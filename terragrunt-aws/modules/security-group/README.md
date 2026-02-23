# Security Group Module - Refactored

Dynamic security group creation module supporting multiple groups in a single configuration.

## Features

- Create multiple security groups from one configuration
- Dynamic ingress/egress rules
- Self-referencing rules for cluster communication
- Default allow-all egress (customizable)

## Usage

```hcl
security_groups = {
  "prod-k8s-sg" = {
    description = "K8s cluster security group"
    ingress_rules = [
      {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        description = "Internal communication"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        self        = true
      }
    ]
    tags = { Role = "k8s" }
  }
  
  "prod-db-sg" = {
    description = "Database security group"
    ingress_rules = [
      {
        description = "PostgreSQL"
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
      }
    ]
    tags = { Role = "database" }
  }
}
```

## Outputs

- `security_group_ids` - Map of security group names to IDs
- `security_group_names` - Map of security group names

## Adding New Security Groups

Add a new entry to the `security_groups` map:

```hcl
"prod-redis-sg" = {
  description = "Redis cache security group"
  ingress_rules = [
    {
      description = "Redis"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
  tags = { Role = "cache" }
}
```
