variable "name" {
  description = "Name of the database (must be PostgreSQL compliant)"
  type = string
}

variable "iam_database_authentication_enabled" {
  type = bool
  default = false
}

variable "instance_count" {
  description = "Number of database instances"
  type = number
  default = 2
}

variable "instance_class" {
  description = "Database instance class"
  type = string
  default = "db.t3.medium"
}

variable "deletion_protection" {
  description = "Boolean flag, if True deletion protection will be enabled"
  type = bool
  default = false
}

variable "security_group_ids" {
  description = "Set of AWS security group IDs to link to the database"
  type = set(string)
}

variable "snapshot_identifier" {
  description = "Optional snapshot identifier to use when provisioning the database"
  type = string
  default = null
}

variable "subnet_ids" {
  description = "Set of AWS subnet IDs in which the database will be provisioned"
  type = set(string)
}

variable "master_username" {
  description = "Database master username"
  type = string
}

variable "master_password" {
  description = "Database master password, if none supplied a random 32 character password will be generated"
  type = string
  default = null
}

variable "backup_retention_period" {
  description = "Backup retention period (number of days)"
  type = number
  default = 30
}

variable "skip_final_snapshot" {
  description = "Boolean flag, if true will skip final snapshot on database deletion"
  type = bool
  default = true
}

variable "storage_encrypted" {
  description = "Boolean flag, if true the contents of the database will be encrypted at rest"
  type = bool
  default = true
}
variable "database_parameters" {
  description = "Database parameters to set"
  type = list(object({
    name = string
    value = number
    apply_method = string
  }))
  default = []
}

variable "database_cluster_parameters" {
  description = "Database cluster parameters to set"
  type = list(object({
    name = string
    value = number
    apply_method = string
  }))
  default = []
}

variable "engine" {
  description = "RDS database engine"
  type = string
  default = "aurora-postgresql"
}

variable "engine_version" {
  description = "RDS database engine version"
  type = string
  default = "11.8"
}

variable "family" {
  description = "RDS database family"
  type = string
  default = "aurora-postgresql11"
}

variable "sns_topic_kms_master_key_id" {
  type = string
  description = "Optional KMS key ID to use for SNS topic encryption"
  default = null
}

variable "performance_insights_kms_key_id" {
  type = string
  description = "Optional KMS key ID to use for performance insights encryption"
  default = null
}