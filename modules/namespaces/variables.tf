variable "create" {
  description = "Whether to create namespaces"
  type        = bool
  default     = false
}

variable "namespaces" {
  description = "List of namespaces to create"
  type = list(object({
    name   = string
    labels = optional(map(string), {})
  }))
  default = []
}
