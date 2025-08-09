locals {
  enabled = var.create
}

# Managed Node Groups
resource "aws_eks_node_group" "managed" {
  for_each = local.enabled ? var.managed_node_groups : {}

  cluster_name    = var.cluster_name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.managed_node_group[each.key].arn
  subnet_ids      = each.value.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types

  dynamic "remote_access" {
    for_each = each.value.remote_access != null ? [each.value.remote_access] : []
    content {
      ec2_ssh_key               = remote_access.value.ec2_ssh_key
      source_security_group_ids = remote_access.value.source_security_group_ids
    }
  }

  dynamic "update_config" {
    for_each = each.value.update_config != null ? [each.value.update_config] : []
    content {
      max_unavailable            = update_config.value.max_unavailable
      max_unavailable_percentage = update_config.value.max_unavailable_percentage
    }
  }

  dynamic "taint" {
    for_each = each.value.taints != null ? each.value.taints : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  labels = each.value.labels

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.cluster_name}-${each.key}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.managed_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.managed_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.managed_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Self-Managed Node Groups (Launch Templates)
resource "aws_launch_template" "node_group" {
  for_each = local.enabled ? var.self_managed_node_groups : {}

  name_prefix   = "${var.cluster_name}-${each.key}-"
  image_id      = each.value.ami_id
  instance_type = each.value.instance_type

  dynamic "block_device_mappings" {
    for_each = each.value.block_device_mappings != null ? each.value.block_device_mappings : []
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size           = block_device_mappings.value.ebs.volume_size
        volume_type           = block_device_mappings.value.ebs.volume_type
        iops                  = try(block_device_mappings.value.ebs.iops, null)
        throughput            = try(block_device_mappings.value.ebs.throughput, null)
        encrypted             = try(block_device_mappings.value.ebs.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.ebs.kms_key_id, null)
        delete_on_termination = try(block_device_mappings.value.ebs.delete_on_termination, true)
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces != null ? each.value.network_interfaces : []
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      delete_on_termination       = network_interfaces.value.delete_on_termination
      device_index                = network_interfaces.value.device_index
      interface_type              = network_interfaces.value.interface_type
      ipv4_address_count          = network_interfaces.value.ipv4_address_count
      ipv4_addresses              = network_interfaces.value.ipv4_addresses
      ipv4_prefix_count           = network_interfaces.value.ipv4_prefix_count
      ipv4_prefixes               = network_interfaces.value.ipv4_prefixes
      ipv6_address_count          = network_interfaces.value.ipv6_address_count
      ipv6_addresses              = network_interfaces.value.ipv6_addresses
      ipv6_prefix_count           = network_interfaces.value.ipv6_prefix_count
      ipv6_prefixes               = network_interfaces.value.ipv6_prefixes
      network_card_index          = network_interfaces.value.network_card_index
      network_interface_id        = network_interfaces.value.network_interface_id
      private_ip_address          = network_interfaces.value.private_ip_address
      subnet_id                   = network_interfaces.value.subnet_id
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    cluster_name           = var.cluster_name
    cluster_endpoint       = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca_certificate
    bootstrap_script       = (try(each.value.bootstrap_script, "") != null ? try(each.value.bootstrap_script, "") : "")
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, try(each.value.tags, {}), {
      Name = "${var.cluster_name}-${each.key}"
    })
  }

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.cluster_name}-${each.key}-lt"
  })
}

# Auto Scaling Groups for Self-Managed Node Groups
resource "aws_autoscaling_group" "node_group" {
  for_each = local.enabled ? var.self_managed_node_groups : {}

  name                      = "${var.cluster_name}-${each.key}"
  desired_capacity          = each.value.desired_size
  max_size                  = each.value.max_size
  min_size                  = each.value.min_size
  target_group_arns         = each.value.target_group_arns
  vpc_zone_identifier       = each.value.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.node_group[each.key].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, try(each.value.tags, {}), {
      Name                                                                    = "${var.cluster_name}-${each.key}"
      "kubernetes.io/cluster/${var.cluster_name}"                             = "owned"
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/role" = "worker"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = each.value.labels != null ? each.value.labels : {}
    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/${tag.key}"
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "tag" {
    for_each = each.value.taints != null ? each.value.taints : []
    iterator = taint_item
    content {
      key                 = "k8s.io/cluster-autoscaler/node-template/taint/${taint_item.value.key}"
      value               = "${taint_item.value.value}:${taint_item.value.effect}"
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
      target_group_arns,
    ]
  }
}

# IAM Roles for Managed Node Groups
resource "aws_iam_role" "managed_node_group" {
  for_each = local.enabled ? var.managed_node_groups : {}

  name = "${var.cluster_name}-${each.key}-managed-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.cluster_name}-${each.key}-managed-node-group-role"
  })
}

# IAM Roles for Self-Managed Node Groups
resource "aws_iam_role" "self_managed_node_group" {
  for_each = local.enabled ? var.self_managed_node_groups : {}

  name = "${var.cluster_name}-${each.key}-self-managed-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name = "${var.cluster_name}-${each.key}-self-managed-node-group-role"
  })
}

# IAM Role Policy Attachments for Managed Node Groups
resource "aws_iam_role_policy_attachment" "managed_node_group_AmazonEKSWorkerNodePolicy" {
  for_each = local.enabled ? var.managed_node_groups : {}

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_node_group[each.key].name
}

resource "aws_iam_role_policy_attachment" "managed_node_group_AmazonEKS_CNI_Policy" {
  for_each = local.enabled ? var.managed_node_groups : {}

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_node_group[each.key].name
}

resource "aws_iam_role_policy_attachment" "managed_node_group_AmazonEC2ContainerRegistryReadOnly" {
  for_each = local.enabled ? var.managed_node_groups : {}

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_node_group[each.key].name
}

# IAM Role Policy Attachments for Self-Managed Node Groups
resource "aws_iam_role_policy_attachment" "self_managed_node_group_AmazonEKSWorkerNodePolicy" {
  for_each = local.enabled ? var.self_managed_node_groups : {}

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.self_managed_node_group[each.key].name
}

resource "aws_iam_role_policy_attachment" "self_managed_node_group_AmazonEKS_CNI_Policy" {
  for_each = local.enabled ? var.self_managed_node_groups : {}

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.self_managed_node_group[each.key].name
}

resource "aws_iam_role_policy_attachment" "self_managed_node_group_AmazonEC2ContainerRegistryReadOnly" {
  for_each = local.enabled ? var.self_managed_node_groups : {}

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.self_managed_node_group[each.key].name
}

# Additional IAM Policies for Managed Node Groups
resource "aws_iam_role_policy" "managed_node_group_additional" {
  for_each = local.enabled ? { for k, v in var.node_group_additional_policies : k => v if contains(keys(var.managed_node_groups), k) } : {}

  name   = "${var.cluster_name}-${each.key}-managed-additional-policy"
  role   = aws_iam_role.managed_node_group[each.key].id
  policy = each.value.policy
}

# Additional IAM Policies for Self-Managed Node Groups
resource "aws_iam_role_policy" "self_managed_node_group_additional" {
  for_each = local.enabled ? { for k, v in var.node_group_additional_policies : k => v if contains(keys(var.self_managed_node_groups), k) } : {}

  name   = "${var.cluster_name}-${each.key}-self-managed-additional-policy"
  role   = aws_iam_role.self_managed_node_group[each.key].id
  policy = each.value.policy
}
