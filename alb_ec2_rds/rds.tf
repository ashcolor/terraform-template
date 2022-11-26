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
  db_subnet_group_name = aws_db_subnet_group.default.name
  cluster_identifier   = "${var.prefix}-db-cluster"
  database_name        = "mydb"
  master_username      = "root"
  master_password      = var.db_root_password
  availability_zones   = ["ap-northeast-1a"]
  # aurora = MySQL 5.6, aurora-mysql=MySQL5.7
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.2"
  backup_retention_period = 7
  # JST 0:00-2:00
  preferred_backup_window = "15:00-17:00"
  skip_final_snapshot     = true
  # JST Mon:02:00-Mon:03:00
  preferred_maintenance_window     = "Sun:17:00-Sun:18:00"
  db_instance_parameter_group_name = aws_db_parameter_group.mysql.name
  vpc_security_group_ids           = [aws_security_group.rds_sg.id]
}


# DB Instance
# Doc:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance
resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = "${var.prefix}-db-instance"
  count               = 1
  cluster_identifier  = aws_rds_cluster.cluster.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.cluster.engine
  engine_version      = aws_rds_cluster.cluster.engine_version
  publicly_accessible = false
}

# DB Instance
# Doc:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
# resource "aws_db_instance" "mysql" {
#   engine                                = "aurora"
#   engine_version                        = "8.0.mysql_aurora.3.02.2"
#   license_model                         = "general-public-license"
#   identifier                            = "${var.prefix}-db-instance"
#   username                              = "${var.db_user}"
#   password                              = "${var.db_password}"
#   instance_class                        = "db.t3.micro"
#   storage_type                          = "gp2"
#   allocated_storage                     = 20
#   max_allocated_storage                 = 100
#   multi_az                              = false
#   availability_zone = "ap-northeast-1a"
#   # For Multi Zone
#   # db_subnet_group_name                  = aws_db_subnet_group.subnet.name
#   publicly_accessible                   = false
#   vpc_security_group_ids                = [aws_security_group.rds_sg.id]
#   port                                  = 3306
#   iam_database_authentication_enabled   = false
#   name                                  = "cloud"
#   parameter_group_name                  = aws_db_parameter_group.mysql.name
#   option_group_name                     = aws_db_option_group.mysql.name
#   backup_retention_period               = 7
#   backup_window                         = "19:00-20:00"
#   copy_tags_to_snapshot                 = true
#   storage_encrypted                     = true
#   # performance_insights_enabled          = true
#   # performance_insights_retention_period = 7
#   monitoring_interval                   = 60
#   monitoring_role_arn                   = aws_iam_role.rds_monitoring_role.arn
#   enabled_cloudwatch_logs_exports       = ["error", "general", "slowquery"]
#   auto_minor_version_upgrade            = false
#   maintenance_window                    = "Sat:20:00-Sat:21:00"
#   deletion_protection                   = false
#   skip_final_snapshot                   = true
#   apply_immediately                     = false

#   tags = {
#     Name = "${var.prefix}-db-instance"
#   }

#   lifecycle {
#     ignore_changes = [password]
#   }
# }

output "rds_endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_rds_cluster.cluster.endpoint
}
