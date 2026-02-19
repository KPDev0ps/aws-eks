# Contributing to AWS EKS Terraform Automation

Thank you for your interest in contributing! This document provides guidelines and information for contributing to this project.

## 🎯 How to Contribute

### Reporting Issues

1. **Search Existing Issues**: Check if your issue already exists
2. **Create Detailed Reports**: Include:
   - Environment (dev/staging/prod)
   - Terraform version
   - AWS region
   - Error messages and logs
   - Steps to reproduce

### Suggesting Enhancements

1. **Check Existing Requests**: Review open feature requests
2. **Provide Context**: Explain:
   - Use case and benefits
   - Proposed implementation approach
   - Backward compatibility considerations

## 🛠️ Development Process

### Prerequisites

- Terraform >= 1.5.7
- AWS CLI configured
- kubectl installed
- Basic understanding of Kubernetes and AWS

### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/KPDev0ps/aws-eks.git
cd aws-eks

# Install pre-commit hooks (optional but recommended)
pre-commit install

# Setup test environment
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with test values
```

### Making Changes

1. **Fork the Repository**
   ```bash
   gh repo fork KPDev0ps/aws-eks --clone
   ```

2. **Create Feature Branch**
   ```bash
   git checkout -b feature/descriptive-name
   # or
   git checkout -b fix/issue-description
   ```

3. **Make Your Changes**
   - Follow [Terraform style guidelines](#terraform-guidelines)
   - Update documentation as needed
   - Add tests when applicable

4. **Test Your Changes**
   ```bash
   # Validate Terraform syntax
   terraform fmt -check -recursive
   terraform validate
   
   # Test in dev environment
   cd environments/dev
   terraform plan
   ```

5. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add new node group configuration options"
   ```

6. **Push and Create PR**
   ```bash
   git push origin feature/descriptive-name
   gh pr create --title "Descriptive Title" --body "Detailed description"
   ```

## 📝 Terraform Guidelines

### Code Style

1. **Formatting**
   ```bash
   terraform fmt -recursive
   ```

2. **Variable Naming**
   - Use snake_case for variables
   - Include descriptions for all variables
   - Set appropriate defaults when possible

3. **Resource Naming**
   - Use consistent prefixes (environment-resource-type)
   - Examples: `dev-eks-cluster`, `prod-vpc-main`

4. **Comments**
   - Document complex logic
   - Explain business requirements
   - Link to relevant AWS documentation

### Module Structure

```
module/
├── main.tf          # Primary resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider requirements
├── README.md        # Module documentation
└── examples/        # Usage examples (optional)
```

### Variable Validation

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## 🧪 Testing

### Validation Tests

All changes are automatically tested via GitHub Actions:

- **Format Check**: `terraform fmt -check`
- **Syntax Validation**: `terraform validate`
- **Security Scan**: Trivy vulnerability scanning
- **Plan Testing**: Terraform plan in multiple environments

### Manual Testing

1. **Test in Development Environment**
   ```bash
   cd environments/dev
   terraform plan
   terraform apply  # If safe to do so
   ```

2. **Validate Outputs**
   ```bash
   terraform output
   kubectl get nodes
   ```

3. **Clean Up**
   ```bash
   terraform destroy  # Don't forget this!
   ```

## 📋 Pull Request Process

### PR Requirements

- [ ] Code follows Terraform style guidelines
- [ ] Changes are tested in development environment  
- [ ] Documentation is updated (README, module docs)
- [ ] Validation workflows pass
- [ ] No hardcoded secrets or account-specific values

### PR Template

Use this template for your PR description:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that causes existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Tested in dev environment
- [ ] Validation workflows pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No hardcoded values
```

### Review Process

1. **Automated Checks**: Must pass all validation workflows
2. **Code Review**: At least one maintainer approval required
3. **Testing**: Changes tested in appropriate environment
4. **Documentation**: Updates to docs reviewed for accuracy

## 🔒 Security Guidelines

### Sensitive Data

- **Never commit**: Secrets, API keys, account IDs
- **Use**: Variables, environment-specific configs  
- **Encrypt**: Terraform state, sensitive outputs

### Access Control

- **Least Privilege**: Grant minimum necessary permissions
- **RBAC**: Use Kubernetes RBAC appropriately
- **IAM**: Follow AWS IAM best practices

### Vulnerability Management

- **Scan**: Use Trivy for security scanning
- **Update**: Keep dependencies current
- **Report**: Security issues privately to maintainers

## 📖 Documentation Standards

### Code Documentation

```hcl
# Create VPC for EKS cluster
# This VPC includes public/private subnets across 3 AZs
# for high availability and proper workload separation
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # ... configuration ...
}
```

### README Updates

- **Keep Current**: Update README with new features
- **Examples**: Provide usage examples
- **Links**: Include relevant external documentation

## 🚨 Troubleshooting Contributions

### Common Issues

1. **Validation Failures**
   ```bash
   # Fix formatting
   terraform fmt -recursive
   
   # Check syntax
   terraform validate
   ```

2. **Test Failures**
   ```bash
   # Ensure clean state
   terraform destroy
   terraform plan
   ```

3. **GitHub Actions Failures**
   - Check workflow logs
   - Ensure all required secrets are set
   - Verify permissions

### Getting Help

- **Documentation**: Check existing docs and examples
- **Issues**: Search existing issues for similar problems
- **Discussions**: Use GitHub Discussions for questions
- **Contact**: Reach out to maintainers if needed

## 🎉 Recognition

Contributors will be:
- Listed in the project contributors
- Mentioned in release notes for significant contributions
- Invited to become maintainers for consistent, high-quality contributions

## 📄 License

By contributing, you agree that your contributions will be licensed under the Mozilla Public License 2.0.

---

**Thank you for contributing!** 🚀