variable "zone_id" { type = string }
variable "record_name" { type = string }
variable "record_type" { type = string; default = "A" }
variable "ttl" { type = number; default = 300 }
variable "records" { type = list(string) }
