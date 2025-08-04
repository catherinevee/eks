# Terragrunt configuration for EKS module
terraform {
  source = "../../"
}

# Include the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = "~> 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = "eks-cluster"
      ManagedBy   = "terragrunt"
    }
  }
}
EOF
}

# Input variables
inputs = {
  cluster_name    = "production-eks-cluster"
  cluster_version = "1.28"
  subnet_ids      = ["subnet-12345678", "subnet-87654321", "subnet-11111111", "subnet-22222222"]

  # VPC Configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["10.0.0.0/8", "172.16.0.0/12"]

  # Node Groups
  node_groups = {
    general = {
      subnet_ids     = ["subnet-12345678", "subnet-87654321"]
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      labels = {
        Environment = "production"
        NodeGroup   = "general"
      }
    }
    spot = {
      subnet_ids     = ["subnet-11111111", "subnet-22222222"]
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
      desired_size   = 1
      max_size       = 3
      min_size       = 0
      labels = {
        Environment = "production"
        NodeGroup   = "spot"
      }
    }
  }

  # Add-ons
  addons = {
    vpc-cni = {
      addon_version = "v1.16.0-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.28.1-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      addon_version = "v2.20.0-eksbuild.1"
    }
  }

  # Logging
  create_cloudwatch_log_group = true
  cluster_log_retention_in_days = 30

  # Tags
  tags = {
    Environment = "production"
    Project     = "eks-cluster"
    ManagedBy   = "terragrunt"
  }
} 