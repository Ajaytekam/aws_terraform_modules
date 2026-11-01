variable "name" { type = string }
variable "visibility_timeout_seconds" { type = number; default = 30 }
variable "message_retention_seconds" { type = number; default = 345600 } # 4 days
variable "delay_seconds" { type = number; default = 0 }
variable "receive_wait_time_seconds" { type = number; default = 20 } # Long polling enabled
variable "kms_master_key_id" { type = string; default = null }
variable "enable_dlq" { type = bool; default = true }
variable "max_receive_count" { type = number; default = 5 }
variable "tags" { type = map(string); default = {} }
