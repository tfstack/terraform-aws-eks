mock_provider "aws" {}
mock_provider "kubernetes" {}
mock_provider "helm" {}

run "plan_minimal" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
  }
}

run "plan_with_encryption" {
  command = plan

  variables {
    create                    = false
    cluster_name              = "test-eks-encrypted"
    cluster_version           = "1.32"
    vpc_id                    = "vpc-00000000000000000"
    private_subnet_ids        = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    enable_cluster_encryption = true
  }
}

run "plan_with_irsa" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-irsa"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    enable_irsa        = true
  }
}

run "plan_with_vpc_config" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-vpc-config"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    cluster_vpc_config = {
      private_subnet_ids      = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
      public_access_cidrs     = ["10.0.0.0/8"]
      endpoint_private_access = true
      endpoint_public_access  = false
      service_cidr            = "10.100.0.0/16"
    }
  }
}

run "plan_with_logging" {
  command = plan

  variables {
    create                          = false
    cluster_name                    = "test-eks-logging"
    cluster_version                 = "1.32"
    vpc_id                          = "vpc-00000000000000000"
    private_subnet_ids              = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    enable_cloudwatch_observability = true
    eks_log_retention_days          = 30
    eks_log_prevent_destroy         = true
  }
}

run "plan_with_addons" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-addons"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    enable_coredns     = true
    enable_kube_proxy  = true
    enable_vpc_cni     = true
    enable_ebs_csi     = true
    enable_efs_csi     = false
  }
}

run "plan_with_namespaces" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-namespaces"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    namespaces = {
      "monitoring" = {
        labels = {
          "app.kubernetes.io/name"    = "monitoring"
          "app.kubernetes.io/part-of" = "observability"
        }
      }
      "logging" = {
        labels = {
          "app.kubernetes.io/name"    = "logging"
          "app.kubernetes.io/part-of" = "observability"
        }
      }
    }
  }
}

run "plan_with_access_entries" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-access"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    access_entries = [
      {
        principal_arn = "arn:aws:iam::123456789012:user/admin"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      },
      {
        principal_arn = "arn:aws:iam::123456789012:role/developer"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
        access_scope = {
          type       = "namespace"
          namespaces = ["default", "monitoring"]
        }
      }
    ]
  }
}

run "plan_with_timeouts" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-timeouts"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    timeouts = {
      create = "30m"
      update = "20m"
      delete = "15m"
    }
  }
}

run "plan_with_upgrade_policy" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-upgrade"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    cluster_upgrade_policy = {
      support_type = "UNSUPPORTED"
    }
  }
}

run "plan_with_zonal_shift" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-zonal"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    cluster_zonal_shift_config = {
      enabled = true
    }
  }
}

run "plan_with_existing_oidc" {
  command = plan

  variables {
    create                     = false
    cluster_name               = "test-eks-existing-oidc"
    cluster_version            = "1.32"
    vpc_id                     = "vpc-00000000000000000"
    private_subnet_ids         = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    enable_oidc                = true
    existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.region.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  }
}

run "plan_with_custom_security_groups" {
  command = plan

  variables {
    create                = false
    cluster_name          = "test-eks-custom-sg"
    cluster_version       = "1.32"
    vpc_id                = "vpc-00000000000000000"
    private_subnet_ids    = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    create_security_group = false
    cluster_vpc_config = {
      security_group_ids = ["sg-aaaaaaaaaaaaaaaaa", "sg-bbbbbbbbbbbbbbbbb"]
    }
  }
}

run "plan_with_tags" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-tagged"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    tags = {
      Environment = "test"
      Project     = "eks-module"
      Owner       = "devops"
      CostCenter  = "infrastructure"
    }
  }
}

run "plan_with_alias_variables" {
  command = plan

  variables {
    create                    = false
    cluster_name              = "test-eks-alias"
    cluster_version           = "1.32"
    vpc_id                    = "vpc-00000000000000000"
    private_subnet_ids        = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    enable_oidc               = true
    enable_cluster_encryption = true
    eks_log_retention_days    = 60
    eks_log_prevent_destroy   = true
  }
}

run "plan_with_all_features" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-complete"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]

    # Encryption
    enable_cluster_encryption = true

    # IRSA
    enable_irsa = true

    # Logging
    cluster_enabled_log_types       = ["api", "audit", "authenticator"]
    enable_cloudwatch_observability = true
    eks_log_retention_days          = 90
    eks_log_prevent_destroy         = true

    # Addons
    enable_coredns    = true
    enable_kube_proxy = true
    enable_vpc_cni    = true
    enable_ebs_csi    = true
    enable_efs_csi    = false

    # Namespaces
    namespaces = {
      "monitoring" = {
        labels = {
          "app.kubernetes.io/name" = "monitoring"
        }
      }
    }

    # Access
    access_entries = [
      {
        principal_arn = "arn:aws:iam::123456789012:user/admin"
        policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      }
    ]

    # Timeouts
    timeouts = {
      create = "45m"
      update = "30m"
      delete = "20m"
    }

    # Tags
    tags = {
      Environment = "test"
      Project     = "eks-module"
      Owner       = "devops"
    }
  }
}

run "validate_outputs" {
  command = plan

  variables {
    create                    = false
    cluster_name              = "test-eks-outputs"
    cluster_version           = "1.32"
    vpc_id                    = "vpc-00000000000000000"
    private_subnet_ids        = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
    enable_irsa               = true
    enable_cluster_encryption = true
  }
}

run "validate_variable_validation" {
  command = plan

  variables {
    create             = false
    cluster_name       = "test-eks-validation"
    cluster_version    = "1.32"
    vpc_id             = "vpc-00000000000000000"
    private_subnet_ids = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]

    # Test alias variables work
    enable_oidc               = true
    enable_cluster_encryption = true
    eks_log_retention_days    = 30
    eks_log_prevent_destroy   = false
  }
}
