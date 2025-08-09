variable "create" {
  description = "Whether to create resources"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Optional existing security group IDs for the cluster"
  type        = list(string)
  default     = null
}

variable "create_security_group" {
  description = "Whether to create the cluster security group"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Public access CIDR blocks for the API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "Private access CIDR blocks for the API endpoint"
  type        = list(string)
  default     = []
}

variable "endpoint_private_access" {
  description = "Whether the endpoint is private accessible"
  type        = bool
  default     = false
}

variable "endpoint_public_access" {
  description = "Whether the endpoint is publicly accessible"
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  description = "Enabled control plane log types"
  type        = list(string)
  default     = []
}

variable "service_cidr" {
  description = "Service IPv4 CIDR"
  type        = string
  default     = null
}

variable "upgrade_policy" {
  description = "Upgrade policy"
  type = object({
    support_type = optional(string, null)
  })
  default = {}
}

variable "zonal_shift_config" {
  description = "Zonal shift config"
  type = object({
    enabled = optional(bool, false)
  })
  default = {}
}

variable "timeouts" {
  description = "Timeouts for cluster operations"
  type = object({
    create = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for secret encryption"
  type        = string
  default     = null
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode"
  type        = string
  default     = "API_AND_CONFIG_MAP"
  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be one of: CONFIG_MAP, API, API_AND_CONFIG_MAP."
  }
}

variable "executor_role_arn" {
  description = "Optional IAM role ARN to grant cluster admin via an EKS access entry"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
