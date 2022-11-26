################################
# RDS
################################
# Subnet Group
resource "aws_db_subnet_group" "default" {
  name = "test"
  subnet_ids = ["${aws_subnet.private_subnet_1a.id}", "${aws_subnet.private_subnet_1c.id}"]

}

# Parameter group
resource "aws_db_parameter_group" "mysql" {
  name   = "${var.prefix}-parameter-group"
  family = "mysql8.0"

  parameter {
    name         = "general_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "long_query_time"
    value        = "0"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_output"
    value        = "FILE"
    apply_method = "immediate"
  }
}

# DB Cluster
# Doc:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster
resource "aws_rds_cluster" "cluster" {
  cluster_identifier               = "${var.prefix}-db-cluster"
  db_subnet_group_name             = aws_db_subnet_group.default.name
  database_name                    = "${var.db_database_name}"
  master_username                  = "root"
  master_password                  = var.db_root_password
  availability_zones               = ["ap-northeast-1a","ap-northeast-1c"]
  engine                           = "aurora-mysql"
  engine_version                   = "8.0.mysql_aurora.3.02.2"
  vpc_security_group_ids           = [aws_security_group.rds_sg.id]
  db_instance_parameter_group_name = aws_db_parameter_group.mysql.name
  backup_retention_period          = 7
  skip_final_snapshot              = true

  # JST 0:00-2:00
  preferred_backup_window          = "15:00-17:00"
  # JST Mon:02:00-Mon:03:00
  preferred_maintenance_window     = "Sun:17:00-Sun:18:00"
}

# DB Instance
# Doc:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = "${var.prefix}-db-instance"
  count               = 1
  cluster_identifier  = aws_rds_cluster.cluster.id
  instance_class      = "${var.db_instance_class}"
  engine              = aws_rds_cluster.cluster.engine
  engine_version      = aws_rds_cluster.cluster.engine_version
  publicly_accessible = false
}

output "rds_endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_rds_cluster.cluster.endpoint
}
