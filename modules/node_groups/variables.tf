variable "create" {
  description = "Whether to create node groups"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  type        = string
}

variable "managed_node_groups" {
  description = "Map of managed node group configurations"
  type = map(object({
    subnet_ids     = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    ami_type       = optional(string)
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
      associate_public_ip_address        = optional(bool)
      delete_on_termination              = optional(bool)
      device_index                       = number
      groups                             = optional(list(string))
      interface_type                     = optional(string)
      ipv4_address_count                 = optional(number)
      ipv4_addresses                     = optional(list(string))
      ipv4_prefix_count                  = optional(number)
      ipv4_prefixes                      = optional(list(string))
      ipv6_address_count                 = optional(number)
      ipv6_addresses                     = optional(list(string))
      ipv6_prefix_count                  = optional(number)
      ipv6_prefixes                      = optional(list(string))
      network_card_index                 = optional(number)
      network_interface_id               = optional(string)
      private_ip_address                 = optional(string)
      private_ip_list                    = optional(list(string))
      secondary_private_ip_address_count = optional(number)
      subnet_id                          = string
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
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
