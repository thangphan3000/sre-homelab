# EC2 Module - Refactored

Dynamic EC2 instance provisioning module that supports multiple instance types (K8s masters, workers, databases, etc.).

## Features

- Dynamic instance creation via map configuration
- Role-based tagging for easy filtering
- Optional SSH key pair generation
- User data support for initialization
- Flexible security group assignment
- SSM integration for secure access

## Usage

```hcl
instances = {
  "prod-k8s-master-1" = {
    ami                         = "ami-xxxxx"
    associate_public_ip_address = true
    instance_type               = "t4g.small"
    subnet_id                   = "subnet-xxxxx"
    security_group_ids          = ["sg-xxxxx"]
    role                        = "k8s-master"
    root_block_device = {
      volume_size = 50
    }
  }
  "prod-k8s-worker-1" = {
    ami                         = "ami-xxxxx"
    instance_type               = "t4g.small"
    subnet_id                   = "subnet-xxxxx"
    security_group_ids          = ["sg-xxxxx"]
    role                        = "k8s-worker"
  }
  "prod-postgres-1" = {
    ami                         = "ami-xxxxx"
    instance_type               = "t4g.medium"
    subnet_id                   = "subnet-xxxxx"
    security_group_ids          = ["sg-xxxxx"]
    role                        = "database"
    root_block_device = {
      volume_size = 100
    }
  }
}
```

## Outputs

- `instance_ids` - Map of instance names to IDs
- `instance_private_ips` - Map of instance names to private IPs
- `instance_public_ips` - Map of instance names to public IPs
- `instances_by_role` - Grouped instances by role

## Adding New Instance Types

Simply add a new entry to the `instances` map with appropriate `role` tag:

```hcl
"prod-redis-1" = {
  ami           = "ami-xxxxx"
  instance_type = "t4g.micro"
  subnet_id     = "subnet-xxxxx"
  role          = "cache"
}
```
