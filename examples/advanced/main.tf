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

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Type = "public"
  }
}

# KMS key for encryption
resource "aws_kms_key" "eks" {
  description             = "EKS cluster encryption key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "eks-encryption-key"
    Environment = "production"
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/eks-encryption-key"
  target_key_id = aws_kms_key.eks.key_id
}

# Security group for EKS cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "eks-cluster-"
  vpc_id      = data.aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-cluster-sg"
    Environment = "production"
  }
}

# Security group for node groups
resource "aws_security_group" "eks_nodes" {
  name_prefix = "eks-nodes-"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-nodes-sg"
    Environment = "production"
  }
}

# IAM role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "eks-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Advanced EKS cluster
module "eks" {
  source = "../../"

  cluster_name    = "production-eks-cluster"
  cluster_version = "1.28"
  subnet_ids      = data.aws_subnets.private.ids

  # VPC Configuration
  endpoint_private_access    = true
  endpoint_public_access     = true
  public_access_cidrs        = ["10.0.0.0/8", "172.16.0.0/12"]
  cluster_security_group_ids = [aws_security_group.eks_cluster.id]

  # Encryption
  cluster_encryption_config = [
    {
      key_arn = aws_kms_key.eks.arn
    }
  ]
  cluster_encryption_resources = ["secrets"]

  # Network Configuration
  service_ipv4_cidr = "10.100.0.0/16"
  ip_family         = "ipv4"

  # Multiple Node Groups
  node_groups = {
    general = {
      subnet_ids      = data.aws_subnets.private.ids
      instance_types  = ["t3.medium", "t3.large"]
      capacity_type   = "ON_DEMAND"
      desired_size    = 2
      max_size        = 4
      min_size        = 1
      max_unavailable = 1
      labels = {
        Environment = "production"
        NodeGroup   = "general"
        Workload    = "general"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "general"
          effect = "NO_SCHEDULE"
        }
      ]
      tags = {
        CostCenter = "12345"
      }
    }
    spot = {
      subnet_ids      = data.aws_subnets.private.ids
      instance_types  = ["t3.medium", "t3.large", "t3.xlarge"]
      capacity_type   = "SPOT"
      desired_size    = 1
      max_size        = 3
      min_size        = 0
      max_unavailable = 1
      labels = {
        Environment = "production"
        NodeGroup   = "spot"
        Workload    = "batch"
      }
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
      tags = {
        CostCenter = "12346"
      }
    }
    gpu = {
      subnet_ids      = data.aws_subnets.private.ids
      instance_types  = ["g4dn.xlarge", "g4dn.2xlarge"]
      capacity_type   = "ON_DEMAND"
      desired_size    = 1
      max_size        = 2
      min_size        = 0
      max_unavailable = 1
      labels = {
        Environment = "production"
        NodeGroup   = "gpu"
        Workload    = "ml"
      }
      taints = [
        {
          key    = "nvidia.com/gpu"
          value  = "present"
          effect = "NO_SCHEDULE"
        }
      ]
      tags = {
        CostCenter = "12347"
      }
    }
  }

  # Comprehensive Add-ons
  addons = {
    aws-ebs-csi-driver = {
      addon_version               = "v2.20.0-eksbuild.1"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
    }
    vpc-cni = {
      addon_version = "v1.16.0-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.28.1-eksbuild.1"
    }
    aws-load-balancer-controller = {
      addon_version = "v2.7.1-eksbuild.1"
    }
  }

  # Fargate Profiles
  fargate_profiles = {
    default = {
      subnet_ids = data.aws_subnets.private.ids
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      tags = {
        Environment = "production"
      }
    }
    monitoring = {
      subnet_ids = data.aws_subnets.private.ids
      selectors = [
        {
          namespace = "monitoring"
          labels    = { Workload = "monitoring" }
        }
      ]
      tags = {
        Environment = "production"
      }
    }
  }

  # Identity Providers
  identity_providers = {
    github = {
      client_id      = "your-github-client-id"
      issuer_url     = "https://token.actions.githubusercontent.com"
      username_claim = "actor"
      groups_claim   = "organization:my-org:role"
      groups_prefix  = "github:"
      required_claims = {
        "repository" = "my-org/my-repo"
      }
      tags = {
        Environment = "production"
      }
    }
  }

  # Access Entries
  access_entries = {
    admin = {
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin"
      type              = "Standard"
      kubernetes_groups = ["system:masters"]
      username          = "admin"
      tags = {
        Environment = "production"
      }
    }
    developer = {
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/developer"
      type              = "Standard"
      kubernetes_groups = ["developers"]
      username          = "developer"
      tags = {
        Environment = "production"
      }
    }
  }

  tags = {
    Environment = "production"
    Project     = "advanced-eks"
    ManagedBy   = "terraform"
    CostCenter  = "12345"
  }
} 