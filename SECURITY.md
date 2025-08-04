# Security Best Practices for EKS Module

This document outlines security best practices and recommendations for using the EKS Terraform module in production environments.

## Cluster Security

### Encryption
- **Enable Encryption at Rest**: Always enable encryption for your EKS cluster using KMS keys
- **Use Customer Managed Keys**: Prefer customer-managed KMS keys over AWS-managed keys for better control
- **Encrypt All Resources**: Ensure all EKS resources (secrets, etc.) are encrypted

```hcl
cluster_encryption_config = [
  {
    key_arn = "arn:aws:kms:region:account:key/key-id"
  }
]
cluster_encryption_resources = ["secrets"]
```

### Network Security
- **Use Private Subnets**: Place EKS clusters in private subnets
- **Restrict Public Access**: Limit public access CIDRs to your organization's IP ranges
- **Security Groups**: Use dedicated security groups with minimal required access

```hcl
endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["10.0.0.0/8", "172.16.0.0/12"]
```

### Control Plane Logging
- **Enable All Log Types**: Enable all control plane logging for audit purposes
- **CloudWatch Logs**: Use CloudWatch for centralized logging
- **Log Retention**: Configure appropriate log retention periods

```hcl
enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
create_cloudwatch_log_group = true
cluster_log_retention_in_days = 30
```

## IAM Security

### Principle of Least Privilege
- **Minimal Permissions**: Grant only necessary permissions to IAM roles
- **Role Separation**: Use separate roles for different components (cluster, nodes, add-ons)
- **Regular Audits**: Regularly review and audit IAM permissions

### IRSA (IAM Roles for Service Accounts)
- **Enable IRSA**: Use IAM roles for service accounts instead of node IAM roles
- **Pod-Level Permissions**: Grant permissions at the pod level for better security

```hcl
enable_irsa = true
```

## Node Security

### Node Group Configuration
- **Use Spot Instances**: Consider using Spot instances for cost optimization
- **Instance Types**: Choose appropriate instance types based on workload requirements
- **Labels and Taints**: Use labels and taints for workload placement and isolation

### Security Groups
- **Node Security Groups**: Configure appropriate ingress/egress rules for node groups
- **Pod-to-Pod Communication**: Use Kubernetes network policies for pod-to-pod communication

## Access Management

### EKS Access Entries
- **Use Access Entries**: Configure EKS access entries for cluster access
- **Role-Based Access**: Use IAM roles instead of IAM users for access
- **Regular Reviews**: Regularly review and update access permissions

```hcl
access_entries = {
  admin = {
    principal_arn     = "arn:aws:iam::account:role/admin-role"
    type              = "Standard"
    kubernetes_groups = ["system:masters"]
  }
}
```

### Identity Providers
- **OIDC Integration**: Use OIDC identity providers for authentication
- **GitHub Actions**: Configure GitHub Actions for CI/CD access
- **Multi-Factor Authentication**: Enable MFA for all user access

## Add-on Security

### Essential Add-ons
- **VPC CNI**: Use AWS VPC CNI for networking
- **CoreDNS**: Essential for DNS resolution
- **kube-proxy**: Required for service networking
- **AWS Load Balancer Controller**: For load balancer management
- **EBS CSI Driver**: For persistent storage

### Add-on Versions
- **Keep Updated**: Regularly update add-on versions for security patches
- **Version Compatibility**: Ensure add-on versions are compatible with your EKS version

## Monitoring and Alerting

### CloudWatch Monitoring
- **Container Insights**: Enable CloudWatch Container Insights for monitoring
- **Custom Metrics**: Set up custom metrics for application monitoring
- **Alerts**: Configure CloudWatch alarms for critical metrics

### Security Monitoring
- **GuardDuty**: Enable AWS GuardDuty for threat detection
- **CloudTrail**: Enable CloudTrail for API call logging
- **Security Hub**: Use AWS Security Hub for security findings

## Compliance and Governance

### Tagging Strategy
- **Resource Tagging**: Implement consistent tagging for cost allocation and governance
- **Security Tags**: Use security-related tags for compliance tracking

```hcl
tags = {
  Environment = "production"
  Project     = "my-project"
  Security    = "high"
  Compliance  = "sox"
}
```

### Backup and Recovery
- **Velero**: Consider using Velero for cluster backup and disaster recovery
- **Regular Backups**: Implement regular backup schedules
- **Recovery Testing**: Regularly test backup and recovery procedures

## Network Policies

### Kubernetes Network Policies
- **Enable Network Policies**: Use Kubernetes network policies for pod-to-pod communication
- **Default Deny**: Implement default deny policies and allow specific traffic
- **Namespace Isolation**: Use network policies for namespace isolation

```hcl
enable_network_policies = true
network_policy_provider = "calico"
```

## Security Scanning

### Container Security
- **Image Scanning**: Scan container images for vulnerabilities
- **Runtime Security**: Use runtime security tools for container monitoring
- **Secrets Management**: Use AWS Secrets Manager or external-secrets for secret management

### Infrastructure Security
- **Terraform Security**: Use security scanning tools like tfsec, Checkov, or Terrascan
- **Code Review**: Implement mandatory security reviews for infrastructure changes
- **Automated Scanning**: Integrate security scanning into CI/CD pipelines

## Incident Response

### Security Incidents
- **Response Plan**: Have a documented incident response plan
- **Communication**: Define communication channels for security incidents
- **Forensics**: Plan for forensic analysis and evidence collection

### Recovery Procedures
- **Cluster Recovery**: Document cluster recovery procedures
- **Data Recovery**: Plan for data recovery from backups
- **Service Restoration**: Define service restoration priorities

## Regular Security Reviews

### Monthly Reviews
- **Access Reviews**: Review and update access permissions
- **Security Updates**: Apply security patches and updates
- **Compliance Checks**: Verify compliance with security policies

### Quarterly Reviews
- **Architecture Review**: Review security architecture and design
- **Threat Modeling**: Conduct threat modeling exercises
- **Security Training**: Provide security training for team members

## Additional Resources

- [AWS EKS Security Best Practices](https://docs.aws.amazon.com/eks/latest/userguide/security.html)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) 