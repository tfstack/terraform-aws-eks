# terraform-aws-eks

Terraform module for AWS EKS clusters

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.13.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.29.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_access"></a> [access](#module\_access) | ./modules/access | n/a |
| <a name="module_addons"></a> [addons](#module\_addons) | ./modules/addons | n/a |
| <a name="module_cloudwatch_logs"></a> [cloudwatch\_logs](#module\_cloudwatch\_logs) | ./modules/cloudwatch_logs | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_encryption"></a> [encryption](#module\_encryption) | ./modules/encryption | n/a |
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ./modules/irsa | n/a |
| <a name="module_namespaces"></a> [namespaces](#module\_namespaces) | ./modules/namespaces | n/a |
| <a name="module_node_groups"></a> [node\_groups](#module\_node\_groups) | ./modules/node_groups | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster_versions.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_entries"></a> [access\_entries](#input\_access\_entries) | Access entries to grant. Provide a list of objects with principal and policy. | <pre>list(object({<br/>    principal_arn     = string<br/>    policy_arn        = string<br/>    kubernetes_groups = optional(list(string), [])<br/>    type              = optional(string)<br/>    access_scope = optional(object({<br/>      type       = string<br/>      namespaces = optional(list(string), [])<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_prevent_destroy"></a> [cloudwatch\_prevent\_destroy](#input\_cloudwatch\_prevent\_destroy) | Whether to set lifecycle prevent\_destroy on log groups | `bool` | `false` | no |
| <a name="input_cloudwatch_retention_in_days"></a> [cloudwatch\_retention\_in\_days](#input\_cloudwatch\_retention\_in\_days) | Retention in days for CloudWatch log groups | `number` | `90` | no |
| <a name="input_cluster_authentication_mode"></a> [cluster\_authentication\_mode](#input\_cluster\_authentication\_mode) | EKS cluster authentication mode | `string` | `"API_AND_CONFIG_MAP"` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | List of enabled cluster control plane log types | `list(string)` | `[]` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | CIDR blocks for which EKS public endpoint is accessible | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_cluster_executor_role_arn"></a> [cluster\_executor\_role\_arn](#input\_cluster\_executor\_role\_arn) | Optional IAM role ARN to grant cluster admin via an EKS access entry | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name | `string` | n/a | yes |
| <a name="input_cluster_upgrade_policy"></a> [cluster\_upgrade\_policy](#input\_cluster\_upgrade\_policy) | Upgrade policy for EKS cluster | <pre>object({<br/>    support_type = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | EKS Kubernetes version, e.g., 1.32 | `string` | n/a | yes |
| <a name="input_cluster_vpc_config"></a> [cluster\_vpc\_config](#input\_cluster\_vpc\_config) | Optional object for full cluster VPC config | <pre>object({<br/>    subnet_ids              = optional(list(string), null)<br/>    private_subnet_ids      = optional(list(string), null)<br/>    private_access_cidrs    = optional(list(string), null)<br/>    public_access_cidrs     = optional(list(string), null)<br/>    service_cidr            = optional(string, null)<br/>    security_group_ids      = optional(list(string), null)<br/>    endpoint_private_access = optional(bool, null)<br/>    endpoint_public_access  = optional(bool, null)<br/>  })</pre> | `null` | no |
| <a name="input_cluster_zonal_shift_config"></a> [cluster\_zonal\_shift\_config](#input\_cluster\_zonal\_shift\_config) | Zonal shift configuration | <pre>object({<br/>    enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_coredns_version"></a> [coredns\_version](#input\_coredns\_version) | Optional version for CoreDNS addon | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create resources. Useful for tests. | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create the cluster security group | `bool` | `true` | no |
| <a name="input_ebs_csi_version"></a> [ebs\_csi\_version](#input\_ebs\_csi\_version) | Optional version for EBS CSI driver addon | `string` | `null` | no |
| <a name="input_efs_csi_version"></a> [efs\_csi\_version](#input\_efs\_csi\_version) | Optional version for EFS CSI driver addon | `string` | `null` | no |
| <a name="input_eks_log_prevent_destroy"></a> [eks\_log\_prevent\_destroy](#input\_eks\_log\_prevent\_destroy) | Alias of cloudwatch\_prevent\_destroy | `bool` | `true` | no |
| <a name="input_eks_log_retention_days"></a> [eks\_log\_retention\_days](#input\_eks\_log\_retention\_days) | Alias of cloudwatch\_retention\_in\_days | `number` | `90` | no |
| <a name="input_enable_cloudwatch_observability"></a> [enable\_cloudwatch\_observability](#input\_enable\_cloudwatch\_observability) | Enable CloudWatch observability features | `bool` | `false` | no |
| <a name="input_enable_cluster_encryption"></a> [enable\_cluster\_encryption](#input\_enable\_cluster\_encryption) | Enable KMS envelope encryption for Kubernetes secrets | `bool` | `false` | no |
| <a name="input_enable_coredns"></a> [enable\_coredns](#input\_enable\_coredns) | Enable CoreDNS addon | `bool` | `true` | no |
| <a name="input_enable_ebs_csi"></a> [enable\_ebs\_csi](#input\_enable\_ebs\_csi) | Enable EBS CSI driver addon | `bool` | `false` | no |
| <a name="input_enable_efs_csi"></a> [enable\_efs\_csi](#input\_enable\_efs\_csi) | Enable EFS CSI driver addon | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Enable IRSA (OIDC provider and optional roles) | `bool` | `false` | no |
| <a name="input_enable_kube_proxy"></a> [enable\_kube\_proxy](#input\_enable\_kube\_proxy) | Enable kube-proxy addon | `bool` | `true` | no |
| <a name="input_enable_oidc"></a> [enable\_oidc](#input\_enable\_oidc) | Enable IAM OIDC provider (alias of enable\_irsa) | `bool` | `false` | no |
| <a name="input_enable_vpc_cni"></a> [enable\_vpc\_cni](#input\_enable\_vpc\_cni) | Enable VPC CNI addon | `bool` | `true` | no |
| <a name="input_encryption_kms_key_arn"></a> [encryption\_kms\_key\_arn](#input\_encryption\_kms\_key\_arn) | Optional pre-existing KMS key ARN for EKS secret encryption | `string` | `null` | no |
| <a name="input_existing_oidc_provider_arn"></a> [existing\_oidc\_provider\_arn](#input\_existing\_oidc\_provider\_arn) | If set, use this OIDC provider ARN instead of creating a new one | `string` | `null` | no |
| <a name="input_kube_proxy_version"></a> [kube\_proxy\_version](#input\_kube\_proxy\_version) | Optional version for kube-proxy addon | `string` | `null` | no |
| <a name="input_managed_node_groups"></a> [managed\_node\_groups](#input\_managed\_node\_groups) | Map of managed node group configurations | <pre>map(object({<br/>    subnet_ids     = list(string)<br/>    desired_size   = number<br/>    max_size       = number<br/>    min_size       = number<br/>    instance_types = list(string)<br/>    remote_access = optional(object({<br/>      ec2_ssh_key               = string<br/>      source_security_group_ids = list(string)<br/>    }))<br/>    update_config = optional(object({<br/>      max_unavailable            = optional(number)<br/>      max_unavailable_percentage = optional(number)<br/>    }))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })))<br/>    labels = optional(map(string))<br/>    tags   = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | Namespaces to create. Accepts either a list of objects [{ name, labels }] or a map(name => { labels }). | `any` | `[]` | no |
| <a name="input_node_group_additional_policies"></a> [node\_group\_additional\_policies](#input\_node\_group\_additional\_policies) | Map of additional IAM policies for node groups | <pre>map(object({<br/>    policy = string<br/>  }))</pre> | `{}` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs for the EKS cluster | `list(string)` | `null` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Optional list of public subnet IDs (unused by default) | `list(string)` | `null` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Map of self-managed node group configurations | <pre>map(object({<br/>    subnet_ids    = list(string)<br/>    desired_size  = number<br/>    max_size      = number<br/>    min_size      = number<br/>    ami_id        = string<br/>    instance_type = string<br/>    block_device_mappings = optional(list(object({<br/>      device_name = string<br/>      ebs = object({<br/>        volume_size           = number<br/>        volume_type           = string<br/>        iops                  = optional(number)<br/>        throughput            = optional(number)<br/>        encrypted             = optional(bool)<br/>        kms_key_id            = optional(string)<br/>        delete_on_termination = optional(bool)<br/>      })<br/>    })))<br/>    network_interfaces = optional(list(object({<br/>      associate_public_ip_address = optional(bool)<br/>      delete_on_termination       = optional(bool)<br/>      device_index                = number<br/>      interface_type              = optional(string)<br/>      ipv4_address_count          = optional(number)<br/>      ipv4_addresses              = optional(list(string))<br/>      ipv4_prefix_count           = optional(number)<br/>      ipv4_prefixes               = optional(list(string))<br/>      ipv6_address_count          = optional(number)<br/>      ipv6_addresses              = optional(list(string))<br/>      ipv6_prefix_count           = optional(number)<br/>      ipv6_prefixes               = optional(list(string))<br/>      network_card_index          = optional(number)<br/>      network_interface_id        = optional(string)<br/>      private_ip_address          = optional(string)<br/>      subnet_id                   = string<br/>    })))<br/>    bootstrap_script  = optional(string)<br/>    target_group_arns = optional(list(string))<br/>    labels            = optional(map(string))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })))<br/>    tags = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeouts for EKS cluster operations | <pre>object({<br/>    create = optional(string, null)<br/>    update = optional(string, null)<br/>    delete = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_cni_version"></a> [vpc\_cni\_version](#input\_vpc\_cni\_version) | Optional version for VPC CNI addon | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the EKS cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_addons_status"></a> [addons\_status](#output\_addons\_status) | Status of managed addons |
| <a name="output_addons_versions"></a> [addons\_versions](#output\_addons\_versions) | Versions of managed addons |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the EKS cluster |
| <a name="output_cluster_auth_token"></a> [cluster\_auth\_token](#output\_cluster\_auth\_token) | Token to use for authentication with the cluster |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the EKS cluster |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | OIDC issuer URL for the cluster |
| <a name="output_managed_node_group_arns"></a> [managed\_node\_group\_arns](#output\_managed\_node\_group\_arns) | ARNs of managed node groups |
| <a name="output_managed_node_group_ids"></a> [managed\_node\_group\_ids](#output\_managed\_node\_group\_ids) | IDs of managed node groups |
| <a name="output_managed_node_group_resources"></a> [managed\_node\_group\_resources](#output\_managed\_node\_group\_resources) | Resource information for managed node groups |
| <a name="output_managed_node_group_role_arns"></a> [managed\_node\_group\_role\_arns](#output\_managed\_node\_group\_role\_arns) | ARNs of managed node group IAM roles |
| <a name="output_managed_node_group_role_names"></a> [managed\_node\_group\_role\_names](#output\_managed\_node\_group\_role\_names) | Names of managed node group IAM roles |
| <a name="output_self_managed_node_group_asg_names"></a> [self\_managed\_node\_group\_asg\_names](#output\_self\_managed\_node\_group\_asg\_names) | Auto scaling group names for self-managed node groups |
| <a name="output_self_managed_node_group_launch_template_ids"></a> [self\_managed\_node\_group\_launch\_template\_ids](#output\_self\_managed\_node\_group\_launch\_template\_ids) | Launch template IDs for self-managed node groups |
| <a name="output_self_managed_node_group_role_arns"></a> [self\_managed\_node\_group\_role\_arns](#output\_self\_managed\_node\_group\_role\_arns) | ARNs of self-managed node group IAM roles |
| <a name="output_self_managed_node_group_role_names"></a> [self\_managed\_node\_group\_role\_names](#output\_self\_managed\_node\_group\_role\_names) | Names of self-managed node group IAM roles |
<!-- END_TF_DOCS -->
