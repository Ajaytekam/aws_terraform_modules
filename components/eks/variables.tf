variable "cluster_name" { type = string }
variable "kubernetes_version" { type = string; default = "1.29" }
variable "subnet_ids" { type = list(string) }
variable "instance_types" { type = list(string); default = ["t3.medium"] }
variable "desired_size" { type = number; default = 2 }
variable "min_size" { type = number; default = 1 }
variable "max_size" { type = number; default = 4 }
