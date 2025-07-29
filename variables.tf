# Cluster Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9\\-]*$", var.cluster_name))
    error_message = "Cluster name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"

  validation {
    condition     = can(regex("^1\\.(2[0-9]|3[0-9])$", var.cluster_version))
    error_message = "Cluster version must be a valid Kubernetes version (1.20-1.39)."
  }
}

# VPC Configuration
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for high availability."
  }
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_security_group_ids" {
  description = "List of security group IDs for the EKS cluster"
  type        = list(string)
  default     = []
}

# Logging Configuration
variable "enabled_cluster_log_types" {
  description = "List of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  validation {
    condition = alltrue([
      for log_type in var.enabled_cluster_log_types : contains([
        "api", "audit", "authenticator", "controllerManager", "scheduler"
      ], log_type)
    ])
    error_message = "Invalid log type. Valid values are: api, audit, authenticator, controllerManager, scheduler."
  }
}

# Encryption Configuration
variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    key_arn = string
  }))
  default = []
}

variable "cluster_encryption_resources" {
  description = "List of strings with resources to be encrypted"
  type        = list(string)
  default     = ["secrets"]
}

# Network Configuration
variable "service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from"
  type        = string
  default     = "10.100.0.0/16"

  validation {
    condition     = can(cidrhost(var.service_ipv4_cidr, 0))
    error_message = "Service IPv4 CIDR must be a valid CIDR block."
  }
}

variable "ip_family" {
  description = "The IP family used to assign Kubernetes pod and service IP addresses"
  type        = string
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "ipv6"], var.ip_family)
    error_message = "IP family must be either 'ipv4' or 'ipv6'."
  }
}

# Node Groups Configuration
variable "node_groups" {
  description = "Map of EKS node groups to create"
  type = map(object({
    subnet_ids      = list(string)
    version         = optional(string)
    capacity_type   = optional(string, "ON_DEMAND")
    instance_types  = list(string)
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = optional(number, 1)
    launch_template = optional(object({
      id      = string
      version = string
    }))
    remote_access = optional(object({
      ec2_ssh_key               = string
      source_security_group_ids = list(string)
    }))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
    labels = optional(map(string))
    tags   = optional(map(string))
  }))
  default = {}
}

# Add-ons Configuration
variable "addons" {
  description = "Map of EKS add-ons to install"
  type = map(object({
    addon_version               = string
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
    configuration_values        = optional(string)
    service_account_role_arn    = optional(string)
    tags                        = optional(map(string))
  }))
  default = {}
}

# Fargate Profiles Configuration
variable "fargate_profiles" {
  description = "Map of EKS Fargate profiles to create"
  type = map(object({
    subnet_ids = list(string)
    selectors = list(object({
      namespace = string
      labels    = optional(map(string))
    }))
    tags = optional(map(string))
  }))
  default = {}
}

# Identity Providers Configuration
variable "identity_providers" {
  description = "Map of EKS identity providers to configure"
  type = map(object({
    client_id       = string
    groups_claim    = optional(string)
    groups_prefix   = optional(string)
    issuer_url      = string
    required_claims = optional(map(string))
    username_claim  = optional(string)
    username_prefix = optional(string)
    tags            = optional(map(string))
  }))
  default = {}
}

# Access Entries Configuration
variable "access_entries" {
  description = "Map of EKS access entries to create"
  type = map(object({
    principal_arn     = string
    type              = string
    kubernetes_groups = optional(list(string))
    username          = optional(string)
    tags              = optional(map(string))
  }))
  default = {}
}

# Access Policy Associations Configuration
variable "access_policy_associations" {
  description = "Map of EKS access policy associations to create"
  type = map(object({
    principal_arn = string
    policy_arn    = string
    access_scope = object({
      type       = string
      namespaces = optional(list(string))
    })
  }))
  default = {}
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
} 