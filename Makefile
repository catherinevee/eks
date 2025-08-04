.PHONY: help init plan apply destroy validate fmt lint clean test test-native security-scan docs pre-commit setup version aws-version test-all security-check validate-all

# Default target
help:
	@echo "Available targets:"
	@echo "  init         - Initialize Terraform"
	@echo "  plan         - Plan Terraform changes"
	@echo "  apply        - Apply Terraform changes"
	@echo "  destroy      - Destroy Terraform resources"
	@echo "  validate     - Validate Terraform configuration"
	@echo "  fmt          - Format Terraform code"
	@echo "  lint         - Lint Terraform code"
	@echo "  clean        - Clean up temporary files"
	@echo "  test         - Run Go-based tests (Terratest)"
	@echo "  test-native  - Run native Terraform tests"
	@echo "  security-scan - Run security scanning"
	@echo "  docs         - Generate documentation"
	@echo "  pre-commit   - Run all pre-commit checks"
	@echo "  setup        - Setup development environment"
	@echo "  version      - Show Terraform version"
	@echo "  aws-version  - Show AWS CLI version"

# Initialize Terraform
init:
	terraform init

# Plan Terraform changes
plan:
	terraform plan -out=tfplan

# Apply Terraform changes
apply:
	terraform apply tfplan

# Destroy Terraform resources
destroy:
	terraform destroy

# Validate Terraform configuration
validate:
	terraform validate

# Format Terraform code
fmt:
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install it from https://github.com/terraform-linters/tflint"; \
	fi

# Clean up temporary files
clean:
	rm -f tfplan
	rm -rf .terraform
	rm -f .terraform.lock.hcl

# Run Go-based tests (requires terratest)
test:
	@if command -v go >/dev/null 2>&1; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "Go not found. Install it to run tests"; \
	fi

# Run native Terraform tests
test-native:
	@if command -v terraform >/dev/null 2>&1; then \
		cd test && terraform test -v; \
	else \
		echo "Terraform not found. Install it to run native tests"; \
	fi

# Security scan (requires terrascan)
security-scan:
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan; \
	else \
		echo "terrascan not found. Install it from https://github.com/tenable/terrascan"; \
	fi

# Documentation
docs:
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md; \
	else \
		echo "terraform-docs not found. Install it from https://github.com/terraform-docs/terraform-docs"; \
	fi

# Pre-commit checks
pre-commit: fmt validate lint test-native
	@echo "Pre-commit checks completed successfully"

# Setup development environment
setup:
	@echo "Setting up development environment..."
	@if ! command -v terraform >/dev/null 2>&1; then \
		echo "Terraform not found. Please install Terraform first."; \
		exit 1; \
	fi
	@if ! command -v aws >/dev/null 2>&1; then \
		echo "AWS CLI not found. Please install AWS CLI first."; \
		exit 1; \
	fi
	@echo "Development environment setup complete"

# Show current Terraform version
version:
	terraform version

# Show AWS CLI version
aws-version:
	aws --version

# Run all tests
test-all: test test-native
	@echo "All tests completed"

# Check for security issues
security-check: security-scan
	@echo "Security scan completed"

# Full validation pipeline
validate-all: fmt validate lint test-native security-scan
	@echo "Full validation pipeline completed successfully" 