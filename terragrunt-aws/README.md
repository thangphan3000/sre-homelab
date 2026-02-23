# Docs

## Project flow
AWS account → AWS region → environment → **common (VPC)** → project(s)

## Wording Guidelines

- Always use **full, explicit names** when specifying values.  
  Avoid abbreviations

  **Examples**
  - Use `production` instead of `prod`
  - Use `staging` instead of `stg`

- Use **snake_case** consistently when defining **locals** and **variables** in Terraform code
- Use **CamelCase** consistently when defining **resource tags**
- Always sort code fields in **alphabetical order** to improve readability
