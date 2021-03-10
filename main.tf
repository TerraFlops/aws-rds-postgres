# Convert the database name into compliant names for cluster/subnet groups
locals {
  database_id = replace(var.name, "_", "-")
  database_id_snake = join("", [for element in split("-", lower(replace(var.name, "_", "-"))) : title(element)])
  database_title = join("", [for element in split("_", replace(lower(var.name), "-", "_")): title(element)])
  database_subnet_group_name = "${local.database_id}-database-subnet-group"
  database_cluster_parameter_group_name = "${local.database_id}-database-cluster-parameter-group"
}

# Create subnet group
resource "aws_db_subnet_group" "subnet_group" {
  name = local.database_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.name
  }
}

# Create parameter group
resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name = local.database_cluster_parameter_group_name
  family = var.family

  dynamic "parameter" {
    for_each = var.database_cluster_parameters
    content {
      name = parameter.value["name"]
      value = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

  tags = {
    Name = var.name
  }
}

# Create random password for database master user
resource "random_password" "master_user_password" {
  length = 32
  special = false
}

# Create database cluster
resource "aws_rds_cluster" "database_cluster" {
  snapshot_identifier = var.snapshot_identifier
  engine_mode = "provisioned"
  engine = var.engine
  engine_version = var.engine_version
  backup_retention_period = var.backup_retention_period
  cluster_identifier = local.database_id
  database_name = var.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  deletion_protection = var.deletion_protection
  master_username = var.master_username
  master_password = var.master_password == null ? random_password.master_user_password.result : var.master_password
  skip_final_snapshot = var.skip_final_snapshot
  storage_encrypted = var.storage_encrypted
  vpc_security_group_ids = var.security_group_ids
  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ]
  tags = {
    Name = var.name
  }
}

resource "aws_iam_role" "monitoring" {
  name = "${local.database_title}RdsMonitoringRole"
  assume_role_policy = data.aws_iam_policy_document.monitoring_rds_trust_policy_document.json
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  role = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy_document" "monitoring_rds_trust_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# Create instances
resource "aws_rds_cluster_instance" "database_cluster_instance" {
  count = var.instance_count
  identifier = "instance-${count.index + 1}"
  instance_class = var.instance_class
  cluster_identifier = aws_rds_cluster.database_cluster.id
  engine = aws_rds_cluster.database_cluster.engine
  engine_version = aws_rds_cluster.database_cluster.engine_version
  performance_insights_enabled = true
  monitoring_interval = 1
  monitoring_role_arn = aws_iam_role.monitoring.arn
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_sns_topic" "database_cluster_alert" {
  name = "${local.database_id_snake}PostgresDatabaseClusterAlert"
  kms_master_key_id = var.sns_topic_kms_master_key_id
}

resource "aws_db_event_subscription" "database_cluster_alert" {
  name = "${local.database_id_snake}PostgresDatabaseInstanceAlert"
  sns_topic = aws_sns_topic.database_cluster_alert.arn
  source_type = "db-cluster"
  source_ids = [
    aws_rds_cluster.database_cluster.id
  ]
  event_categories = [
    "failover",
    "maintenance",
    "notification"
  ]
}