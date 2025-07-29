output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_ids" {
  description = "Security group IDs attached to the EKS cluster"
  value       = module.eks.cluster_security_group_ids
}

output "cluster_iam_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = module.eks.cluster_iam_role_arn
}

output "node_groups" {
  description = "Map of EKS node groups"
  value       = module.eks.node_groups
}

output "node_group_iam_role_arns" {
  description = "Map of node group IAM role ARNs"
  value       = module.eks.node_group_iam_role_arns
}

output "addons" {
  description = "Map of EKS add-ons"
  value       = module.eks.addons
}

output "fargate_profiles" {
  description = "Map of EKS Fargate profiles"
  value       = module.eks.fargate_profiles
}

output "fargate_profile_iam_role_arns" {
  description = "Map of Fargate profile IAM role ARNs"
  value       = module.eks.fargate_profile_iam_role_arns
}

output "identity_providers" {
  description = "Map of EKS identity providers"
  value       = module.eks.identity_providers
}

output "access_entries" {
  description = "Map of EKS access entries"
  value       = module.eks.access_entries
}

output "kubeconfig" {
  description = "Kubeconfig configuration for the EKS cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for cluster encryption"
  value       = aws_kms_key.eks.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for cluster encryption"
  value       = aws_kms_key.eks.key_id
} 