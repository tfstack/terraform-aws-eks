output "managed_node_group_arns" {
  description = "ARNs of managed node groups"
  value = {
    for k, v in aws_eks_node_group.managed : k => v.arn
  }
}

output "managed_node_group_ids" {
  description = "IDs of managed node groups"
  value = {
    for k, v in aws_eks_node_group.managed : k => v.id
  }
}

output "managed_node_group_resources" {
  description = "Resource information for managed node groups"
  value = {
    for k, v in aws_eks_node_group.managed : k => {
      arn            = v.arn
      id             = v.id
      status         = v.status
      scaling_config = v.scaling_config
    }
  }
}

output "self_managed_node_group_launch_template_ids" {
  description = "Launch template IDs for self-managed node groups"
  value = {
    for k, v in aws_launch_template.node_group : k => v.id
  }
}

output "self_managed_node_group_asg_names" {
  description = "Auto scaling group names for self-managed node groups"
  value = {
    for k, v in aws_autoscaling_group.node_group : k => v.name
  }
}

output "managed_node_group_role_arns" {
  description = "ARNs of managed node group IAM roles"
  value = {
    for k, v in aws_iam_role.managed_node_group : k => v.arn
  }
}

output "managed_node_group_role_names" {
  description = "Names of managed node group IAM roles"
  value = {
    for k, v in aws_iam_role.managed_node_group : k => v.name
  }
}

output "self_managed_node_group_role_arns" {
  description = "ARNs of self-managed node group IAM roles"
  value = {
    for k, v in aws_iam_role.self_managed_node_group : k => v.arn
  }
}

output "self_managed_node_group_role_names" {
  description = "Names of self-managed node group IAM roles"
  value = {
    for k, v in aws_iam_role.self_managed_node_group : k => v.name
  }
}
