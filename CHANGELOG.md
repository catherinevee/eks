# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enhanced variable validation for node groups and add-ons
- Conditional security group creation when not provided
- CloudWatch log group support with configurable retention
- Native Terraform tests (`.tftest.hcl` files)
- Terragrunt example configuration
- Comprehensive resource map in README
- Lifecycle management for EKS cluster to prevent accidental deletion
- Enhanced Makefile with additional testing and validation targets

### Changed
- Updated provider version constraints to AWS ~> 6.2.0 and Terraform ~> 1.13.0
- Enhanced output descriptions with usage examples
- Improved error messages in variable validations

### Fixed
- Removed invalid `username` attribute from EKS access entry resource
- Updated all examples to use consistent provider versions

## [1.0.0] - 2024-01-XX

### Added
- Initial release of EKS Terraform module
- Support for EKS cluster creation with configurable Kubernetes versions
- Node groups with multiple instance types and capacity types
- Fargate profiles for serverless compute
- EKS add-ons management
- OIDC identity providers
- EKS access entries and policy associations
- Comprehensive IAM role management
- Security group support
- CloudWatch logging integration
- Go-based tests using Terratest
- Basic and advanced examples
- Comprehensive documentation

### Features
- EKS cluster with encryption at rest
- Multiple node group support
- Fargate profile support
- Add-on management
- Identity provider configuration
- Access management
- Security and networking features
- Monitoring and logging
- Tagging support
- High availability configurations 