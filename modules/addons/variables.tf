variable "create" {
  description = "Whether to create addons"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Effective Kubernetes version for resolving addon versions"
  type        = string
}

variable "enable_coredns" {
  type    = bool
  default = true
}

variable "coredns_version" {
  type    = string
  default = null
}

variable "enable_kube_proxy" {
  type    = bool
  default = true
}

variable "kube_proxy_version" {
  type    = string
  default = null
}

variable "enable_vpc_cni" {
  type    = bool
  default = true
}

variable "vpc_cni_version" {
  type    = string
  default = null
}

variable "enable_ebs_csi" {
  type    = bool
  default = false
}

variable "ebs_csi_version" {
  type    = string
  default = null
}

variable "enable_efs_csi" {
  type    = bool
  default = false
}

variable "efs_csi_version" {
  type    = string
  default = null
}
