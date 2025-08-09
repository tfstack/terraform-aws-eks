############################################
# Terraform & Provider Configuration
############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

############################################
# Random Suffix for Resource Names
############################################

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

############################################
# Local Variables
############################################

locals {
  azs                 = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  name                = "cltest"
  base_name           = local.suffix != "" ? "${local.name}-${local.suffix}" : local.name
  suffix              = random_string.suffix.result
  private_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  region              = "ap-southeast-2"
  vpc_cidr            = "10.0.0.0/16"
  eks_cluster_version = "1.33"
  service_cidr        = "10.100.0.0/16"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

############################################
# VPC Configuration
############################################

module "vpc" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name           = local.base_name
  vpc_cidr           = local.vpc_cidr
  availability_zones = local.azs

  public_subnet_cidrs  = local.public_subnets
  private_subnet_cidrs = local.private_subnets

  # Enable Internet Gateway & NAT Gateway
  # A single NAT gateway is used instead of multiple for cost efficiency.
  create_igw       = true
  nat_gateway_type = "single"

  tags = local.tags

  enable_eks_tags  = true
  eks_cluster_name = local.base_name
}

############################################
# EKS Module
############################################

module "eks" {
  source = "../../"

  create          = true
  vpc_id          = module.vpc.vpc_id
  cluster_name    = local.base_name
  cluster_version = "latest"
  tags            = local.tags

  cluster_vpc_config = {
    private_subnet_ids  = module.vpc.private_subnet_ids
    public_access_cidrs = ["0.0.0.0/0"]
    service_cidr        = local.service_cidr

    security_group_ids      = []
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  enable_cluster_encryption       = true
  enable_oidc                     = true
  enable_irsa                     = true
  enable_cloudwatch_observability = true

  eks_log_prevent_destroy = false
  eks_log_retention_days  = 1

  enable_coredns  = true
  coredns_version = "latest"

  enable_kube_proxy  = true
  kube_proxy_version = "latest"

  enable_vpc_cni  = true
  vpc_cni_version = "latest"

  enable_ebs_csi  = true
  ebs_csi_version = "latest"

  enable_efs_csi  = true
  efs_csi_version = "latest"

  managed_node_groups = {
    general = {
      subnet_ids     = module.vpc.private_subnet_ids
      desired_size   = 2
      max_size       = 5
      min_size       = 1
      instance_types = ["t3.medium"]
      labels = {
        "node.kubernetes.io/role"          = "worker"
        "node.kubernetes.io/instance-type" = "t3.medium"
      }
      tags = {
        Environment = "dev"
      }
    }
    spot = {
      subnet_ids     = module.vpc.private_subnet_ids
      desired_size   = 1
      max_size       = 3
      min_size       = 0
      instance_types = ["t3.medium", "t3.small"]
      labels = {
        "node.kubernetes.io/role"          = "worker"
        "node.kubernetes.io/instance-type" = "spot"
      }
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
      tags = {
        Environment = "dev"
        Spot        = "true"
      }
    }
  }

  namespaces = [
    {
      name = "monitoring"
      labels = {
        "app.kubernetes.io/name" = "monitoring"
      }
    },
    {
      name = "logging"
      labels = {
        "app.kubernetes.io/name" = "logging"
      }
    }
  ]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  token                  = module.eks.cluster_auth_token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_ca_certificate
    token                  = module.eks.cluster_auth_token
  }
}
