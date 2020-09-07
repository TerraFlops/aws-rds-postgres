# Terraflops Terraform Module
 
### AWS PostgreSQL Database

This module can be used to create a PostgreSQL database

#### Example usage

```hcl-terraform
module "application_database" {
  source = "git::https://github.com/TerraFlops/aws-rds-postgres-serverless?ref=v1.1"
  name = "example"
  master_username = "company_master"
  # Restore from snapshot
  snapshot_identifier = "initial-snapshot-id"
  security_group_ids = [
    module.vpc.security_group_ids["database"]
  ]
  subnet_ids = [
    module.vpc.subnet_ids["database_subnet_2a"],
    module.vpc.subnet_ids["database_subnet_2b"]
  ]
  storage_encrypted = true
  skip_final_snapshot = true
}
```
