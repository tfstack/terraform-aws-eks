# Addons module

Manages core EKS addons (CoreDNS, kube-proxy, VPC CNI, EBS CSI, EFS CSI).

## Usage

```hcl
module "addons" {
  source          = "./modules/addons"
  create          = true
  cluster_name    = module.cluster.cluster_name
  cluster_version = "1.31"

  enable_coredns  = true
}
```

## Inputs

- **create**: bool (default: true)
- **cluster_name**: string
- **cluster_version**: string
- **enable_coredns**: bool (default: true)
- **coredns_version**: string (default: null)
- **enable_kube_proxy**: bool (default: true)
- **kube_proxy_version**: string (default: null)
- **enable_vpc_cni**: bool (default: true)
- **vpc_cni_version**: string (default: null)
- **enable_ebs_csi**: bool (default: false)
- **ebs_csi_version**: string (default: null)
- **enable_efs_csi**: bool (default: false)
- **efs_csi_version**: string (default: null)

## Outputs

- **ids**: Addon IDs keyed by addon name (null if disabled)
- **versions**: Addon versions keyed by addon name (null if disabled)
