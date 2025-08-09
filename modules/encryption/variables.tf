variable "create" {
  description = "Whether to create KMS key"
  type        = bool
  default     = false
}

variable "alias_name" {
  description = "KMS alias name (without alias/ prefix)"
  type        = string
  default     = "eks"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
