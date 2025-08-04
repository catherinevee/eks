# AWS EKS Terraform Module

A comprehensive Terraform module for creating and managing Amazon Elastic Kubernetes Service (EKS) clusters with support for node groups, Fargate profiles, add-ons, and more.

## Features

- **EKS Cluster**: Create EKS clusters with configurable Kubernetes versions
- **Node Groups**: Support for multiple node groups with different instance types and configurations
- **Fargate Profiles**: Serverless compute for Kubernetes pods
- **Add-ons**: Install and manage EKS add-ons (AWS Load Balancer Controller, CoreDNS, etc.)
- **Identity Providers**: Configure OIDC identity providers for authentication
- **Access Management**: EKS access entries and policy associations
- **Security**: Encryption at rest, security groups, and IAM roles
- **Networking**: Configurable VPC settings, endpoint access, and IP families

## Usage

### Basic Example

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

### Advanced Example

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

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

### Required

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_name | Name of the EKS cluster | `string` | n/a |
| subnet_ids | List of subnet IDs for the EKS cluster | `list(string)` | n/a |

### Optional

| Name | Description | Type | Default |
|------|-------------|------|---------|
| cluster_version | Kubernetes version for the EKS cluster | `string` | `"1.28"` |
| endpoint_private_access | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `true` |
| endpoint_public_access | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` |
| public_access_cidrs | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | `["0.0.0.0/0"]` |
| cluster_security_group_ids | List of security group IDs for the EKS cluster | `list(string)` | `[]` |
| enabled_cluster_log_types | List of the desired control plane logging to enable | `list(string)` | `["api", "audit", "authenticator", "controllerManager", "scheduler"]` |
| cluster_encryption_config | Configuration block with encryption configuration for the cluster | `list(object({ key_arn = string }))` | `[]` |
| cluster_encryption_resources | List of strings with resources to be encrypted | `list(string)` | `["secrets"]` |
| service_ipv4_cidr | The CIDR block to assign Kubernetes service IP addresses from | `string` | `"10.100.0.0/16"` |
| ip_family | The IP family used to assign Kubernetes pod and service IP addresses | `string` | `"ipv4"` |
| node_groups | Map of EKS node groups to create | `map(object({ ... }))` | `{}` |
| addons | Map of EKS add-ons to install | `map(object({ ... }))` | `{}` |
| fargate_profiles | Map of EKS Fargate profiles to create | `map(object({ ... }))` | `{}` |
| identity_providers | Map of EKS identity providers to configure | `map(object({ ... }))` | `{}` |
| access_entries | Map of EKS access entries to create | `map(object({ ... }))` | `{}` |
| access_policy_associations | Map of EKS access policy associations to create | `map(object({ ... }))` | `{}` |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | EKS cluster ID |
| cluster_arn | The Amazon Resource Name (ARN) of the cluster |
| cluster_endpoint | The endpoint for your EKS Kubernetes API |
| cluster_oidc_issuer_url | The URL on the EKS cluster for the OpenID Connect identity provider |
| node_groups | Map of EKS node groups created |
| addons | Map of EKS add-ons created |
| fargate_profiles | Map of EKS Fargate profiles created |
| kubeconfig | Kubeconfig configuration for the EKS cluster |

## Node Group Configuration

Node groups support the following configuration options:

```hcl
node_groups = {
  example = {
    subnet_ids         = ["subnet-12345678", "subnet-87654321"]
    version            = "1.28"  # Optional, defaults to cluster version
    capacity_type      = "ON_DEMAND"  # ON_DEMAND or SPOT
    instance_types     = ["t3.medium", "t3.large"]
    desired_size       = 2
    max_size           = 4
    min_size           = 1
    max_unavailable    = 1
    launch_template    = {  # Optional
      id      = "lt-12345678"
      version = "$Latest"
    }
    remote_access = {  # Optional
      ec2_ssh_key               = "my-key"
      source_security_group_ids = ["sg-12345678"]
    }
    taints = [  # Optional
      {
        key    = "dedicated"
        value  = "example"
        effect = "NO_SCHEDULE"
      }
    ]
    labels = {  # Optional
      Environment = "production"
      NodeGroup   = "example"
    }
    tags = {  # Optional
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

## Resource Map

This module creates the following resources:

### Core EKS Resources
- **aws_eks_cluster.main** - The main EKS cluster
- **aws_iam_role.eks_cluster** - IAM role for the EKS cluster
- **aws_iam_role_policy_attachment.eks_cluster_policy** - Attaches AmazonEKSClusterPolicy
- **aws_iam_role_policy_attachment.eks_vpc_resource_controller** - Attaches AmazonEKSVPCResourceController

### Node Groups
- **aws_eks_node_group.main** - EKS node groups (one per entry in var.node_groups)
- **aws_iam_role.eks_node_group** - IAM roles for node groups (one per node group)
- **aws_iam_role_policy_attachment.eks_worker_node_policy** - Attaches AmazonEKSWorkerNodePolicy
- **aws_iam_role_policy_attachment.eks_cni_policy** - Attaches AmazonEKS_CNI_Policy
- **aws_iam_role_policy_attachment.ec2_container_registry_read_only** - Attaches AmazonEC2ContainerRegistryReadOnly

### Add-ons
- **aws_eks_addon.main** - EKS add-ons (one per entry in var.addons)

### Fargate Profiles
- **aws_eks_fargate_profile.main** - Fargate profiles (one per entry in var.fargate_profiles)
- **aws_iam_role.eks_fargate_profile** - IAM roles for Fargate profiles (one per profile)
- **aws_iam_role_policy_attachment.eks_fargate_pod_execution_role_policy** - Attaches AmazonEKSFargatePodExecutionRolePolicy

### Identity and Access Management
- **aws_eks_identity_provider_config.main** - OIDC identity providers (one per entry in var.identity_providers)
- **aws_eks_access_entry.main** - EKS access entries (one per entry in var.access_entries)
- **aws_eks_access_policy_association.main** - Access policy associations (one per entry in var.access_policy_associations)

### Security Groups (Conditional)
- **aws_security_group.cluster** - Cluster security group (if var.cluster_security_group_ids is empty)
- **aws_security_group.node** - Node security group (if var.node_groups have security group configurations)

### CloudWatch Resources (Conditional)
- **aws_cloudwatch_log_group.cluster** - CloudWatch log group for cluster logs (if var.create_cloudwatch_log_group = true)

### Data Sources
- **aws_iam_policy_document.cluster_assume_role** - IAM policy document for cluster assume role
- **aws_iam_policy_document.node_assume_role** - IAM policy document for node assume role
- **aws_iam_policy_document.fargate_assume_role** - IAM policy document for Fargate assume role

## Best Practices

### Security

1. **Enable Encryption**: Always enable encryption at rest for your EKS cluster
2. **Use Private Subnets**: Place your EKS cluster in private subnets for better security
3. **Restrict Public Access**: Limit public access CIDRs to your organization's IP ranges
4. **Enable Control Plane Logging**: Enable all control plane log types for audit purposes
5. **Use IAM Roles**: Use IAM roles instead of access keys for authentication

### Networking

1. **High Availability**: Use at least 2 subnets across different Availability Zones
2. **VPC Planning**: Plan your VPC CIDR blocks carefully to avoid conflicts
3. **Security Groups**: Use dedicated security groups for your EKS cluster
4. **Network Policies**: Implement Kubernetes network policies for pod-to-pod communication

### Node Groups

1. **Instance Types**: Choose appropriate instance types based on your workload requirements
2. **Capacity Types**: Use SPOT instances for cost optimization where possible
3. **Scaling**: Configure appropriate min/max sizes for auto-scaling
4. **Labels and Taints**: Use labels and taints for workload placement

### Monitoring and Logging

1. **CloudWatch Logs**: Enable control plane logging to CloudWatch
2. **Metrics**: Use CloudWatch Container Insights for monitoring
3. **Alerts**: Set up CloudWatch alarms for critical metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository or contact the maintainers.