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
}

# Data sources for existing VPC resources
data "aws_vpc" "main" {
  tags = {
    Name = "main-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Type = "private"
  }
}

# Basic EKS cluster
module "eks" {
  source = "../../"

  cluster_name    = "basic-eks-cluster"
  cluster_version = "1.28"
  subnet_ids      = data.aws_subnets.private.ids

  # Basic node group
  node_groups = {
    general = {
      subnet_ids     = data.aws_subnets.private.ids
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      capacity_type  = "ON_DEMAND"
    }
  }

  # Essential add-ons
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
  }

  tags = {
    Environment = "development"
    Project     = "basic-eks"
    ManagedBy   = "terraform"
  }
} 