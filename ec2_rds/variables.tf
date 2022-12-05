# Common
variable "prefix" {
  description = "プロジェクトプリフィックス"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "VPC CIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

# EC2
variable "web_instance_class" {
  description = "WEBサーバインスタンスクラス"
  type        = string
}


# RDS
variable "db_instance_class" {
  description = "DBインスタンスクラス"
  type        = string
}

variable "db_database_name" {
  description = "DBデータベース名"
  type        = string
}

variable "db_root_password" {
  description = "DBルートパスワード"
  type        = string
}
