# Basic EKS cluster test
run "create_basic_eks_cluster" {
  command = plan

  variables {
    cluster_name    = "test-eks-cluster"
    cluster_version = "1.28"
    subnet_ids      = ["subnet-12345678", "subnet-87654321"]
    node_groups = {
      test = {
        subnet_ids     = ["subnet-12345678", "subnet-87654321"]
        instance_types = ["t3.medium"]
        desired_size   = 1
        max_size       = 2
        min_size       = 1
      }
    }
    tags = {
      Test = "true"
    }
  }

  assert {
    condition     = aws_eks_cluster.main.name == "test-eks-cluster"
    error_message = "Cluster name should match the input variable"
  }

  assert {
    condition     = aws_eks_cluster.main.version == "1.28"
    error_message = "Cluster version should match the input variable"
  }

  assert {
    condition     = length(aws_eks_node_group.main) == 1
    error_message = "Should create exactly one node group"
  }
}

run "validate_cluster_outputs" {
  command = plan

  variables {
    cluster_name    = "test-eks-cluster"
    cluster_version = "1.28"
    subnet_ids      = ["subnet-12345678", "subnet-87654321"]
    node_groups = {
      test = {
        subnet_ids     = ["subnet-12345678", "subnet-87654321"]
        instance_types = ["t3.medium"]
        desired_size   = 1
        max_size       = 2
        min_size       = 1
      }
    }
  }

  assert {
    condition     = output.cluster_id == aws_eks_cluster.main.id
    error_message = "Cluster ID output should match the cluster resource ID"
  }

  assert {
    condition     = output.cluster_arn == aws_eks_cluster.main.arn
    error_message = "Cluster ARN output should match the cluster resource ARN"
  }

  assert {
    condition     = output.cluster_endpoint == aws_eks_cluster.main.endpoint
    error_message = "Cluster endpoint output should match the cluster resource endpoint"
  }
}

run "validate_node_group_outputs" {
  command = plan

  variables {
    cluster_name    = "test-eks-cluster"
    cluster_version = "1.28"
    subnet_ids      = ["subnet-12345678", "subnet-87654321"]
    node_groups = {
      test = {
        subnet_ids     = ["subnet-12345678", "subnet-87654321"]
        instance_types = ["t3.medium"]
        desired_size   = 1
        max_size       = 2
        min_size       = 1
      }
    }
  }

  assert {
    condition     = length(output.node_groups) == 1
    error_message = "Should have exactly one node group in outputs"
  }

  assert {
    condition     = contains(keys(output.node_groups), "test")
    error_message = "Node group outputs should contain the 'test' node group"
  }
} 