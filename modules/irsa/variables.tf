variable "create" {
  description = "Whether to create IRSA OIDC provider"
  type        = bool
  default     = false
}

variable "cluster_oidc_issuer_url" {
  description = "Cluster OIDC issuer URL"
  type        = string
}

variable "existing_oidc_provider_arn" {
  description = "Existing OIDC provider ARN, if provided this module will not create a new one"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
