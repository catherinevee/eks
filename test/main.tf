terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Test VPC and networking
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "eks-test-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "test"
    Project     = "eks-module-test"
  }
}

# Test EKS cluster
module "eks" {
  source = "../"

  cluster_name    = "test-eks-cluster"
  cluster_version = "1.28"
  subnet_ids      = module.vpc.private_subnets

  # Basic node group for testing
  node_groups = {
    test = {
      subnet_ids     = module.vpc.private_subnets
      instance_types = ["t3.small"]
      desired_size   = 1
      max_size       = 2
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
    Environment = "test"
    Project     = "eks-module-test"
    ManagedBy   = "terraform"
  }
} 