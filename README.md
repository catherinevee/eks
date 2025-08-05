# AWS EKS Terraform Module

Terraform module for creating Amazon Elastic Kubernetes Service (EKS) clusters with enterprise security, monitoring, and scalability features.

## Features

- EKS clusters with configurable Kubernetes versions
- Multiple node groups with different instance types and configurations
- Fargate profiles for serverless compute
- EKS add-ons for AWS Load Balancer Controller, CoreDNS, and more
- OIDC identity providers for authentication
- EKS access entries and policy associations
- Encryption at rest, security groups, and IAM roles
- Configurable VPC settings, endpoint access, and IP families

## Usage

### Basic EKS Cluster

```hcl
module "eks" {
  source = "./eks"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.28"
  subnet_ids      = ["subnet-12345678", "subnet-87654321"]

  node_groups = {
    general = {
      subnet_ids     = ["subnet-12345678", "subnet-87654321"]
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 4
      min_size       = 1
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced EKS Cluster

```hcl
module "eks" {
  source = "./eks"

  cluster_name    = "production-eks"
  cluster_version = "1.28"
  subnet_ids      = ["subnet-12345678", "subnet-87654321", "subnet-11111111", "subnet-22222222"]

  # VPC Configuration
  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["10.0.0.0/8", "172.16.0.0/12"]

  # Encryption
  cluster_encryption_config = [
    {
      key_arn = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-1234-1234-1234-123456789012"
    }
  ]
  cluster_encryption_resources = ["secrets"]

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
      taints = [
        {
          key    = "dedicated"
          value  = "general"
          effect = "NO_SCHEDULE"
        }
      ]
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
    aws-ebs-csi-driver = {
      addon_version = "v2.20.0-eksbuild.1"
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
  }

  # Fargate Profiles
  fargate_profiles = {
    default = {
      subnet_ids = ["subnet-12345678", "subnet-87654321"]
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
    }
  }

  # Identity Providers
  identity_providers = {
    github = {
      client_id  = "your-github-client-id"
      issuer_url = "https://token.actions.githubusercontent.com"
      username_claim = "actor"
      groups_claim = "organization:my-org:role"
    }
  }

  # Access Entries
  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::123456789012:user/admin"
      type          = "Standard"
      kubernetes_groups = ["system:masters"]
      username         = "admin"
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

### Required

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_name | EKS cluster name | `string` | n/a |
| subnet_ids | Subnet IDs for EKS cluster | `list(string)` | n/a |

### Optional

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_version | Kubernetes version | `string` | `"1.28"` |
| endpoint_private_access | Enable private API endpoint | `bool` | `true` |
| endpoint_public_access | Enable public API endpoint | `bool` | `true` |
| public_access_cidrs | Public access CIDR blocks | `list(string)` | `["0.0.0.0/0"]` |
| cluster_security_group_ids | Cluster security group IDs | `list(string)` | `[]` |
| enabled_cluster_log_types | Control plane logging types | `list(string)` | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` |
| cluster_encryption_config | Encryption configuration | `list(object({ key_arn = string }))` | `[]` |
| cluster_encryption_resources | Resources to encrypt | `list(string)` | `["secrets"]` |
| service_ipv4_cidr | Service IP CIDR block | `string` | `"10.100.0.0/16"` |
| ip_family | IP family for pods and services | `string` | `"ipv4"` |
| node_groups | Node group configurations | `map(object({ ... }))` | `{}` |
| addons | EKS add-on configurations | `map(object({ ... }))` | `{}` |
| fargate_profiles | Fargate profile configurations | `map(object({ ... }))` | `{}` |
| identity_providers | Identity provider configurations | `map(object({ ... }))` | `{}` |
| access_entries | Access entry configurations | `map(object({ ... }))` | `{}` |
| access_policy_associations | Access policy associations | `map(object({ ... }))` | `{}` |
| tags | Resource tags | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | EKS cluster ID |
| cluster_arn | Cluster ARN |
| cluster_endpoint | Kubernetes API endpoint |
| cluster_oidc_issuer_url | OIDC issuer URL |
| node_groups | Node group outputs |
| addons | Add-on outputs |
| fargate_profiles | Fargate profile outputs |
| kubeconfig | Kubeconfig configuration |

## Node Group Configuration

Node groups support the following configuration options:

```hcl
node_groups = {
  example = {
    subnet_ids         = ["subnet-12345678", "subnet-87654321"]
    version            = "1.28"
    capacity_type      = "ON_DEMAND"
    instance_types     = ["t3.medium", "t3.large"]
    desired_size       = 2
    max_size           = 4
    min_size           = 1
    max_unavailable    = 1
    launch_template    = {
      id      = "lt-12345678"
      version = "$Latest"
    }
    remote_access = {
      ec2_ssh_key               = "my-key"
      source_security_group_ids = ["sg-12345678"]
    }
    taints = [
      {
        key    = "dedicated"
        value  = "example"
        effect = "NO_SCHEDULE"
      }
    ]
    labels = {
      Environment = "production"
      NodeGroup   = "example"
    }
    tags = {
      CostCenter = "12345"
    }
  }
}
```

## Add-ons Configuration

EKS add-ons can be configured as follows:

```hcl
addons = {
  aws-ebs-csi-driver = {
    addon_version                = "v2.20.0-eksbuild.1"
    resolve_conflicts_on_create  = "OVERWRITE"
    resolve_conflicts_on_update  = "OVERWRITE"
    configuration_values         = "{\"controller\":{\"serviceAccount\":{\"create\":true}}}"
    service_account_role_arn     = "arn:aws:iam::123456789012:role/eks-addon-ebs-csi-driver"
    tags = {
      Environment = "production"
    }
  }
}
```

## Fargate Profile Configuration

Fargate profiles can be configured as follows:

```hcl
fargate_profiles = {
  default = {
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
    selectors = [
      {
        namespace = "default"
        labels    = { Environment = "production" }
      },
      {
        namespace = "kube-system"
      }
    ]
    tags = {
      Environment = "production"
    }
  }
}
```

## Identity Provider Configuration

OIDC identity providers can be configured as follows:

```hcl
identity_providers = {
  github = {
    client_id     = "your-github-client-id"
    issuer_url    = "https://token.actions.githubusercontent.com"
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
```

## Access Entry Configuration

EKS access entries can be configured as follows:

```hcl
access_entries = {
  admin = {
    principal_arn     = "arn:aws:iam::123456789012:user/admin"
    type              = "Standard"
    kubernetes_groups = ["system:masters"]
    username          = "admin"
    tags = {
      Environment = "production"
    }
  }
}
```

## Resource Architecture

This module creates the following resources:

### Core EKS Resources
- `aws_eks_cluster.main` - Main EKS cluster
- `aws_iam_role.eks_cluster` - IAM role for EKS cluster
- `aws_iam_role_policy_attachment.eks_cluster_policy` - AmazonEKSClusterPolicy
- `aws_iam_role_policy_attachment.eks_vpc_resource_controller` - AmazonEKSVPCResourceController

### Node Groups
- `aws_eks_node_group.main` - EKS node groups
- `aws_iam_role.eks_node_group` - IAM roles for node groups
- `aws_iam_role_policy_attachment.eks_worker_node_policy` - AmazonEKSWorkerNodePolicy
- `aws_iam_role_policy_attachment.eks_cni_policy` - AmazonEKS_CNI_Policy
- `aws_iam_role_policy_attachment.ec2_container_registry_read_only` - AmazonEC2ContainerRegistryReadOnly

### Add-ons
- `aws_eks_addon.main` - EKS add-ons

### Fargate Profiles
- `aws_eks_fargate_profile.main` - Fargate profiles
- `aws_iam_role.eks_fargate_profile` - IAM roles for Fargate profiles
- `aws_iam_role_policy_attachment.eks_fargate_pod_execution_role_policy` - AmazonEKSFargatePodExecutionRolePolicy

### Identity and Access Management
- `aws_eks_identity_provider_config.main` - OIDC identity providers
- `aws_eks_access_entry.main` - EKS access entries
- `aws_eks_access_policy_association.main` - Access policy associations

### Security Groups (Conditional)
- `aws_security_group.cluster` - Cluster security group
- `aws_security_group.node` - Node security group

### CloudWatch Resources (Conditional)
- `aws_cloudwatch_log_group.cluster` - CloudWatch log group for cluster logs

### Data Sources
- `aws_iam_policy_document.cluster_assume_role` - IAM policy document for cluster assume role
- `aws_iam_policy_document.node_assume_role` - IAM policy document for node assume role
- `aws_iam_policy_document.fargate_assume_role` - IAM policy document for Fargate assume role

## Best Practices

### Security

1. Enable encryption at rest for your EKS cluster
2. Place your EKS cluster in private subnets
3. Limit public access CIDRs to your organization's IP ranges
4. Enable all control plane log types for audit purposes
5. Use IAM roles instead of access keys for authentication

### Networking

1. Use at least 2 subnets across different Availability Zones
2. Plan your VPC CIDR blocks carefully to avoid conflicts
3. Use dedicated security groups for your EKS cluster
4. Implement Kubernetes network policies for pod-to-pod communication

### Node Groups

1. Choose appropriate instance types based on your workload requirements
2. Use SPOT instances for cost optimization where possible
3. Configure appropriate min/max sizes for auto-scaling
4. Use labels and taints for workload placement

### Monitoring and Logging

1. Enable control plane logging to CloudWatch
2. Use CloudWatch Container Insights for monitoring
3. Set up CloudWatch alarms for critical metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

For support and questions, please open an issue in the repository or contact the maintainers.