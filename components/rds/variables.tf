variable "db_name" {
  description = "Identifier name for the database instance and associated resources"
  type        = string
  default     = "appdb-instance"
}
variable "database_name" { type = string; default = "appdb" }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "engine" { type = string; default = "postgres" }
variable "engine_version" { type = string; default = "15.4" }
variable "instance_class" { type = string; default = "db.t3.micro" }
variable "allocated_storage" { type = number; default = 20 }
variable "port" { type = number; default = 5432 }
variable "username" { type = string; default = "dbadmin" }
variable "password" { type = string; sensitive = true }
variable "allowed_cidr_blocks" { type = list(string); default = ["10.0.0.0/16"] }
variable "skip_final_snapshot" { type = bool; default = true }
variable "tags" { type = map(string); default = {} }
