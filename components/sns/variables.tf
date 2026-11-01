variable "name" { type = string }
variable "kms_key_id" { type = string; default = "alias/aws/sns" }
variable "subscriptions" {
  description = "Map of subscriptions"
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {}
}
variable "tags" { type = map(string); default = {} }
