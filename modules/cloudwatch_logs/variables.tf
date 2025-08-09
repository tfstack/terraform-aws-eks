variable "create" {
  description = "Whether to create log groups"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "retention_in_days" {
  description = "Retention in days"
  type        = number
  default     = 90
}

variable "prevent_destroy" {
  description = "Prevent destroy lifecycle"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for log groups"
  type        = map(string)
  default     = {}
}
