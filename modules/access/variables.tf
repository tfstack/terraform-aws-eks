variable "create" {
  description = "Whether to manage access entries"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "access_entries" {
  description = "Map of access entries to create, keyed by principal ARN"
  type = map(object({
    policy_arn        = string
    principal_arn     = optional(string)
    kubernetes_groups = optional(list(string), [])
    type              = optional(string)
    access_scope = optional(object({
      type       = string
      namespaces = optional(list(string), [])
    }), null)
  }))
  default = {}
}
