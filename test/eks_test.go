package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEKSModule(t *testing.T) {
	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./",
		Vars: map[string]interface{}{
			"cluster_name": "test-eks-cluster",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			".*": "Retryable error",
		},
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	clusterID := terraform.Output(t, terraformOptions, "cluster_id")
	clusterEndpoint := terraform.Output(t, terraformOptions, "cluster_endpoint")
	vpcID := terraform.Output(t, terraformOptions, "vpc_id")

	// Assertions
	assert.NotEmpty(t, clusterID, "Cluster ID should not be empty")
	assert.NotEmpty(t, clusterEndpoint, "Cluster endpoint should not be empty")
	assert.NotEmpty(t, vpcID, "VPC ID should not be empty")

	// Verify EKS cluster exists
	region := aws.GetRandomStableRegion(t, nil, nil)
	cluster := aws.GetEksCluster(t, region, clusterID)
	assert.Equal(t, "ACTIVE", *cluster.Status, "EKS cluster should be active")

	// Verify VPC exists
	vpc := aws.GetVpcById(t, vpcID, region)
	assert.NotNil(t, vpc, "VPC should exist")
}

func TestEKSModuleWithCustomVars(t *testing.T) {
	// Configure Terraform options with custom variables
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./",
		Vars: map[string]interface{}{
			"cluster_name":    "custom-test-eks-cluster",
			"cluster_version": "1.28",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	})

	// Clean up resources at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	clusterID := terraform.Output(t, terraformOptions, "cluster_id")
	clusterEndpoint := terraform.Output(t, terraformOptions, "cluster_endpoint")

	// Assertions
	assert.NotEmpty(t, clusterID, "Cluster ID should not be empty")
	assert.NotEmpty(t, clusterEndpoint, "Cluster endpoint should not be empty")
	assert.Contains(t, clusterID, "custom-test-eks-cluster", "Cluster ID should contain custom name")
}
