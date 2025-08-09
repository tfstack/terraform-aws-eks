variable "create" {
  description = "Whether to create resources. Useful for tests."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version, e.g., 1.32"
  type        = string
}

variable "cluster_enabled_log_types" {
  description = "List of enabled cluster control plane log types"
  type        = list(string)
  default     = []
}

variable "cluster_upgrade_policy" {
  description = "Upgrade policy for EKS cluster"
  type = object({
    support_type = optional(string, null)
  })
  default = {}
}

variable "cluster_zonal_shift_config" {
  description = "Zonal shift configuration"
  type = object({
    enabled = optional(bool, false)
  })
  default = {}
}

variable "cluster_executor_role_arn" {
  description = "Optional IAM role ARN to grant cluster admin via an EKS access entry"
  type        = string
  default     = null
}

variable "cluster_authentication_mode" {
  description = "EKS cluster authentication mode"
  type        = string
  default     = "API_AND_CONFIG_MAP"
  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.cluster_authentication_mode)
    error_message = "authentication_mode must be one of: CONFIG_MAP, API, API_AND_CONFIG_MAP."
  }
}

variable "timeouts" {
  description = "Timeouts for EKS cluster operations"
  type = object({
    create = optional(string, null)
    update = optional(string, null)
    delete = optional(string, null)
  })
  default = {}
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
  default     = null
}

variable "public_subnet_ids" {
  description = "Optional list of public subnet IDs (unused by default)"
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks for which EKS public endpoint is accessible"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_vpc_config" {
  description = "Optional object for full cluster VPC config"
  type = object({
    subnet_ids              = optional(list(string), null)
    private_subnet_ids      = optional(list(string), null)
    private_access_cidrs    = optional(list(string), null)
    public_access_cidrs     = optional(list(string), null)
    service_cidr            = optional(string, null)
    security_group_ids      = optional(list(string), null)
    endpoint_private_access = optional(bool, null)
    endpoint_public_access  = optional(bool, null)
  })
  default = null
}

variable "create_security_group" {
  description = "Whether to create the cluster security group"
  type        = bool
  default     = true
}

variable "enable_irsa" {
  description = "Enable IRSA (OIDC provider and optional roles)"
  type        = bool
  default     = false
}

variable "enable_oidc" {
  description = "Enable IAM OIDC provider (alias of enable_irsa)"
  type        = bool
  default     = false
}

variable "existing_oidc_provider_arn" {
  description = "If set, use this OIDC provider ARN instead of creating a new one"
  type        = string
  default     = null
}

variable "enable_cluster_encryption" {
  description = "Enable KMS envelope encryption for Kubernetes secrets"
  type        = bool
  default     = false
}

variable "encryption_kms_key_arn" {
  description = "Optional pre-existing KMS key ARN for EKS secret encryption"
  type        = string
  default     = null
}

variable "enable_coredns" {
  description = "Enable CoreDNS addon"
  type        = bool
  default     = true
}

variable "coredns_version" {
  description = "Optional version for CoreDNS addon"
  type        = string
  default     = null
}

variable "enable_kube_proxy" {
  description = "Enable kube-proxy addon"
  type        = bool
  default     = true
}

variable "kube_proxy_version" {
  description = "Optional version for kube-proxy addon"
  type        = string
  default     = null
}

variable "enable_vpc_cni" {
  description = "Enable VPC CNI addon"
  type        = bool
  default     = true
}

variable "vpc_cni_version" {
  description = "Optional version for VPC CNI addon"
  type        = string
  default     = null
}

variable "enable_ebs_csi" {
  description = "Enable EBS CSI driver addon"
  type        = bool
  default     = false
}

variable "ebs_csi_version" {
  description = "Optional version for EBS CSI driver addon"
  type        = string
  default     = null
}

variable "enable_efs_csi" {
  description = "Enable EFS CSI driver addon"
  type        = bool
  default     = false
}

variable "efs_csi_version" {
  description = "Optional version for EFS CSI driver addon"
  type        = string
  default     = null
}

variable "namespaces" {
  description = "Namespaces to create. Accepts either a list of objects [{ name, labels }] or a map(name => { labels })."
  type        = any
  default     = []
}

variable "access_entries" {
  description = "Access entries to grant. Provide a list of objects with principal and policy."
  type = list(object({
    principal_arn     = string
    policy_arn        = string
    kubernetes_groups = optional(list(string), [])
    type              = optional(string)
    access_scope = optional(object({
      type       = string
      namespaces = optional(list(string), [])
    }), null)
  }))
  default = []
  validation {
    condition = alltrue([
      for entry in var.access_entries : alltrue([
        for group in try(entry.kubernetes_groups, []) : !startswith(group, "system:")
      ])
    ])
    error_message = "Kubernetes groups cannot start with 'system:' when using EKS access entries. Use access policies instead."
  }
}

variable "cloudwatch_retention_in_days" {
  description = "Retention in days for CloudWatch log groups"
  type        = number
  default     = 90
}

variable "cloudwatch_prevent_destroy" {
  description = "Whether to set lifecycle prevent_destroy on log groups"
  type        = bool
  default     = false
}

variable "eks_log_retention_days" {
  description = "Alias of cloudwatch_retention_in_days"
  type        = number
  default     = 90
}

variable "eks_log_prevent_destroy" {
  description = "Alias of cloudwatch_prevent_destroy"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_observability" {
  description = "Enable CloudWatch observability features"
  type        = bool
  default     = false
}

# Node Groups Variables
variable "managed_node_groups" {
  description = "Map of managed node group configurations"
  type = map(object({
    subnet_ids     = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    remote_access = optional(object({
      ec2_ssh_key               = string
      source_security_group_ids = list(string)
    }))
    update_config = optional(object({
      max_unavailable            = optional(number)
      max_unavailable_percentage = optional(number)
    }))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
    labels = optional(map(string))
    tags   = optional(map(string))
  }))
  default = {}
}

variable "self_managed_node_groups" {
  description = "Map of self-managed node group configurations"
  type = map(object({
    subnet_ids    = list(string)
    desired_size  = number
    max_size      = number
    min_size      = number
    ami_id        = string
    instance_type = string
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = object({
        volume_size           = number
        volume_type           = string
        iops                  = optional(number)
        throughput            = optional(number)
        encrypted             = optional(bool)
        kms_key_id            = optional(string)
        delete_on_termination = optional(bool)
      })
    })))
    network_interfaces = optional(list(object({
      associate_public_ip_address = optional(bool)
      delete_on_termination       = optional(bool)
      device_index                = number
      interface_type              = optional(string)
      ipv4_address_count          = optional(number)
      ipv4_addresses              = optional(list(string))
      ipv4_prefix_count           = optional(number)
      ipv4_prefixes               = optional(list(string))
      ipv6_address_count          = optional(number)
      ipv6_addresses              = optional(list(string))
      ipv6_prefix_count           = optional(number)
      ipv6_prefixes               = optional(list(string))
      network_card_index          = optional(number)
      network_interface_id        = optional(string)
      private_ip_address          = optional(string)
      subnet_id                   = string
    })))
    bootstrap_script  = optional(string)
    target_group_arns = optional(list(string))
    labels            = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
    tags = optional(map(string))
  }))
  default = {}
}

variable "node_group_additional_policies" {
  description = "Map of additional IAM policies for node groups"
  type = map(object({
    policy = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
