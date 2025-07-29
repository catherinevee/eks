# Cluster Information
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_eks_cluster.main.role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

output "cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = aws_eks_cluster.main.version
}

# Node Groups Information
output "node_groups" {
  description = "Map of EKS node groups created"
  value = {
    for k, v in aws_eks_node_group.main : k => {
      arn             = v.arn
      id              = v.id
      node_group_name = v.node_group_name
      node_role_arn   = v.node_role_arn
      status          = v.status
      subnet_ids      = v.subnet_ids
      version         = v.version
      capacity_type   = v.capacity_type
      instance_types  = v.instance_types
      scaling_config  = v.scaling_config
      update_config   = v.update_config
      labels          = v.labels
      tags            = v.tags
    }
  }
}

output "node_group_arns" {
  description = "List of all node group ARNs"
  value       = [for ng in aws_eks_node_group.main : ng.arn]
}

output "node_group_ids" {
  description = "List of all node group IDs"
  value       = [for ng in aws_eks_node_group.main : ng.id]
}

# IAM Roles Information
output "cluster_iam_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "node_group_iam_role_arns" {
  description = "Map of node group IAM role ARNs"
  value = {
    for k, v in aws_iam_role.eks_node_group : k => v.arn
  }
}

# Add-ons Information
output "addons" {
  description = "Map of EKS add-ons created"
  value = {
    for k, v in aws_eks_addon.main : k => {
      arn           = v.arn
      addon_name    = v.addon_name
      addon_version = v.addon_version
      cluster_name  = v.cluster_name
      status        = v.status
      tags          = v.tags
    }
  }
}

# Fargate Profiles Information
output "fargate_profiles" {
  description = "Map of EKS Fargate profiles created"
  value = {
    for k, v in aws_eks_fargate_profile.main : k => {
      arn                    = v.arn
      fargate_profile_name   = v.fargate_profile_name
      cluster_name           = v.cluster_name
      pod_execution_role_arn = v.pod_execution_role_arn
      subnet_ids             = v.subnet_ids
      status                 = v.status
      tags                   = v.tags
    }
  }
}

output "fargate_profile_iam_role_arns" {
  description = "Map of Fargate profile IAM role ARNs"
  value = {
    for k, v in aws_iam_role.eks_fargate_profile : k => v.arn
  }
}

# Identity Providers Information
output "identity_providers" {
  description = "Map of EKS identity providers configured"
  value = {
    for k, v in aws_eks_identity_provider_config.main : k => {
      arn                           = v.arn
      cluster_name                  = v.cluster_name
      identity_provider_config_name = v.identity_provider_config_name
      status                        = v.status
      tags                          = v.tags
    }
  }
}

# Access Entries Information
output "access_entries" {
  description = "Map of EKS access entries created"
  value = {
    for k, v in aws_eks_access_entry.main : k => {
      arn               = v.arn
      cluster_name      = v.cluster_name
      principal_arn     = v.principal_arn
      type              = v.type
      kubernetes_groups = v.kubernetes_groups
      username          = v.username
      tags              = v.tags
    }
  }
}

# Access Policy Associations Information
output "access_policy_associations" {
  description = "Map of EKS access policy associations created"
  value = {
    for k, v in aws_eks_access_policy_association.main : k => {
      cluster_name  = v.cluster_name
      principal_arn = v.principal_arn
      policy_arn    = v.policy_arn
      access_scope  = v.access_scope
    }
  }
}

# Security Groups Information
output "cluster_security_group_ids" {
  description = "List of security group IDs associated with the cluster"
  value       = aws_eks_cluster.main.vpc_config[0].security_group_ids
}

# Network Information
output "cluster_subnet_ids" {
  description = "List of subnet IDs associated with the cluster"
  value       = aws_eks_cluster.main.vpc_config[0].subnet_ids
}

output "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  value       = aws_eks_cluster.main.vpc_config[0].endpoint_private_access
}

output "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  value       = aws_eks_cluster.main.vpc_config[0].endpoint_public_access
}

output "cluster_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  value       = aws_eks_cluster.main.vpc_config[0].public_access_cidrs
}

# Kubernetes Configuration
output "kubeconfig" {
  description = "Kubeconfig configuration for the EKS cluster"
  value = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        name = aws_eks_cluster.main.name
        cluster = {
          certificate-authority-data = aws_eks_cluster.main.certificate_authority[0].data
          server                     = aws_eks_cluster.main.endpoint
        }
      }
    ]
    contexts = [
      {
        name = aws_eks_cluster.main.name
        context = {
          cluster = aws_eks_cluster.main.name
          user    = aws_eks_cluster.main.name
        }
      }
    ]
    users = [
      {
        name = aws_eks_cluster.main.name
        user = {
          exec = {
            apiVersion = "client.authentication.k8s.io/v1beta1"
            command    = "aws"
            args = [
              "eks",
              "get-token",
              "--cluster-name",
              aws_eks_cluster.main.name
            ]
          }
        }
      }
    ]
  })
  sensitive = true
} 