# Node groups module

Creates managed and self-managed node groups for an EKS cluster.

## Usage

```hcl
module "node_groups" {
  source                 = "./modules/node_groups"
  create                 = true
  cluster_name           = module.cluster.cluster_name
  cluster_endpoint       = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = module.cluster.eks_cluster_ca_cert

  managed_node_groups = {
    default = {
      subnet_ids     = ["subnet-aaaa", "subnet-bbbb", "subnet-cccc"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.medium"]
    }
  }
}
```

## Inputs

- **create**: bool (default: true)
- **cluster_name**: string
- **cluster_endpoint**: string
- **cluster_ca_certificate**: string
- **managed_node_groups**: map(object({...})) (default: {})
  - Supports `ami_type` (optional); defaults to `AL2023_x86_64_STANDARD` if not set
- **self_managed_node_groups**: map(object({...})) (default: {})
- **node_group_additional_policies**: map(object({ policy = string })) (default: {})
- **tags**: map(string) (default: {})

## Outputs

- **managed_node_group_arns**
- **managed_node_group_ids**
- **managed_node_group_resources**
- **self_managed_node_group_launch_template_ids**
- **self_managed_node_group_asg_names**
- **managed_node_group_role_arns**
- **managed_node_group_role_names**
- **self_managed_node_group_role_arns**
- **self_managed_node_group_role_names**
