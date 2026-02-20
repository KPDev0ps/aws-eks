# AWS EKS Terraform Automation

[![Terraform Validation](https://github.com/KPDev0ps/aws-eks/actions/workflows/terraform-validation.yml/badge.svg)](https://github.com/KPDev0ps/aws-eks/actions/workflows/terraform-validation.yml)

A complete, production-ready solution for deploying Amazon EKS clusters using Terraform and GitHub Actions. This repository provides a standardized approach to EKS deployment across multiple environments (dev, staging, production) with automated CI/CD pipelines using AWS predefined modules.

## 🚀 Features

- **Multi-Environment Support**: Separate configurations for dev, staging, and production
- **AWS Predefined Modules**: Uses official AWS Terraform modules for reliability and best practices
- **GitHub Actions Integration**: Automated deployment and validation workflows  
- **Security-First**: OIDC authentication, encrypted storage, security scanning
- **Cost Optimized**: Environment-specific resource sizing
- **Production Ready**: High availability, monitoring, and best practices

## 📁 Repository Structure

```
├── .github/
│   ├── actions/                     # Custom GitHub Actions
│   │   └── tf-matrix/              # Terraform change detection action
│   └── workflows/                   # GitHub Actions workflows
│       ├── terraform-plan.yml       # Plan-only workflow (runs on PRs)
│       ├── terraform-apply.yml      # Plan+apply workflow (runs on main pushes)
│       ├── eks-destroy.yml          # Destroy EKS clusters
│       └── terraform-validation.yml  # Code validation and security
├── terraform/
│   └── aws/
│       └── overlay/                 # Environment-specific configurations
│           ├── dev/                 # Development environment
│           │   └── eks/             # EKS resources
│           ├── staging/             # Staging environment
│           │   └── eks/             # EKS resources
│           └── prod/                # Production environment
│               └── eks/             # EKS resources
├── .gitignore                       # Git ignore rules
├── terraform.tfvars.example         # Example configuration
├── CONTRIBUTING.md                  # Contribution guidelines
├── REPOSITORY_SETUP.md              # GitHub repository configuration guide
└── README.md                        # This file
```

## 🎯 Enhanced Workflow Features

### 🔄 Intelligent Change Detection
- **Automatic detection** of changed Terraform directories
- **Matrix strategy** runs jobs only for modified environments
- **Path-based triggers** on `terraform/aws/overlay/**` changes

### 🛡️ Approval Gates & Protection
- **Separate plan/apply workflows** for clear separation of concerns
- **Environment-based approval requirements** for apply operations
- **Branch protection** requires PR approval and status checks
- **Environment protection rules**:
  - `dev`: Optional approval (fast iteration)
  - `staging`: 1 required approval
  - `prod`: 2 required approvals + 10-minute cooling period

### 📋 Workflow Triggers

#### Plan Workflow (`terraform-plan.yml`)
- **Pull Requests**: Automatic plan for changed environments only
- **Manual dispatch**: Target specific environments with plan-only
- **PR Integration**: Plan outputs commented directly on PRs
- **Status checks**: Required to pass before PR merge

#### Apply Workflow (`terraform-apply.yml`)  
- **Main branch push**: Automatic plan+apply for changed environments (with approvals)
- **Manual dispatch**: Target specific environments with plan+apply
- **Auto cleanup**: Source branch deleted automatically after successful apply
- **Environment gates**: Enforced approval requirements before apply

### 💬 PR Integration
- **Plan output** automatically commented on pull requests
- **Status checks** prevent merging without successful plans
- **Change summaries** show which environments will be affected
- **Updated comments** replace previous plan results for same environment

## 📚 Repository Configuration

**Important**: Before using the workflows, you must configure GitHub repository settings for branch protection and environment approvals.

👉 **See [REPOSITORY_SETUP.md](.github/REPOSITORY_SETUP.md) for detailed setup instructions**

Key requirements:
- Environment protection rules (`dev`, `staging`, `prod`)
- Branch protection for `main` with required status checks
- GitHub secret `OIDC_ROLE_ARN` configured

## 🛠️ Prerequisites

Before you begin, ensure you have:

1. **AWS Account**: With appropriate permissions for EKS, VPC, IAM
2. **Terraform**: Version >= 1.5.7
3. **AWS CLI**: Configured with your credentials
4. **kubectl**: For interacting with the cluster
5. **GitHub Repository**: With OIDC configured for AWS

## ⚙️ Setup Instructions

### 1. Repository Setup

```bash
# Clone the repository
git clone https://github.com/KPDev0ps/aws-eks.git
cd aws-eks
```

### 2. Configure AWS Authentication

#### Option A: OIDC (Recommended for GitHub Actions)
Set up OIDC trust relationship between GitHub and AWS:

1. Create an OIDC provider in AWS IAM
2. Create a role with the necessary permissions
3. Add the role ARN to GitHub secrets as `OIDC_ROLE_ARN`

#### Option B: Local Development
```bash
aws configure
# or use AWS profiles
export AWS_PROFILE=your-profile-name
```

### 3. Initialize Terraform Backend

Update the S3 backend configuration in each environment's `main.tf`:

```hcl
backend "s3" {
  bucket  = "your-terraform-state-bucket"
  key     = "eks/{environment}/terraform.tfstate"
  region  = "your-region"
  encrypt = true
}
```

### 4. Environment Configuration

Customize the terraform.tfvars file for your environment:

```bash
cd terraform/aws/overlay/dev/eks
# Edit terraform.tfvars with your values
```

## 🚀 Usage

### Manual Deployment

```bash
# Navigate to your environment
cd terraform/aws/overlay/dev/eks

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

### GitHub Actions Deployment

1. **Deploy Infrastructure**:
   - Go to Actions tab in GitHub
   - Run "EKS Apply" workflow
   - Select environment and action (plan/apply)

2. **Destroy Infrastructure** (when needed):
   - Run "EKS Destroy" workflow
   - Type "DESTROY" to confirm
   - Select environment

### Connect to Your Cluster

After deployment, connect to your EKS cluster:

```bash
# Get the kubectl config command from Terraform outputs
aws eks --region us-east-2 update-kubeconfig --name dev-eks-cluster

# Verify connection
kubectl get nodes
```

## 🏗️ Architecture

### Network Architecture
- **VPC**: Dedicated VPC per environment using AWS VPC module
- **Subnets**: Public and private subnets across 3 AZs
- **NAT Gateway**: Single NAT for dev, multiple for prod
- **Security Groups**: Least-privilege access

### EKS Configuration
- **Control Plane**: Managed by AWS using official EKS module
- **Node Groups**: AL2023 with EBS CSI driver
- **Addons**: CoreDNS, VPC CNI, Kube-proxy, Pod Identity Agent
- **Storage**: GP3 encrypted volumes

### AWS Modules Used
- **VPC Module**: `terraform-aws-modules/vpc/aws` (~> 5.13)
- **EKS Module**: `terraform-aws-modules/eks/aws` (~> 20.33)

### Security Features
- **OIDC Provider**: For service account authentication
- **Encryption**: At rest and in transit
- **IAM Roles**: Least privilege principle
- **Network Policies**: Secure pod communication

## 🌍 Environment Configurations

| Feature | Dev | Staging | Production |
|---------|-----|---------|------------|
| **VPC CIDR** | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| **NAT Gateway** | Single | Multiple | Multiple |
| **Instance Type** | t3.medium | t3.large | m5.xlarge |
| **Node Count** | 1-3 | 2-6 | 3-10 |
| **Public Access** | Enabled | Enabled | Disabled |
| **Spot Instances** | No | No | Yes |

## 🔧 Customization

### Adding New Environments

1. Create new directory: `terraform/aws/overlay/your-env/eks/`
2. Copy files from existing environment
3. Customize variables and backend configuration
4. Update GitHub Actions workflow choices

### Configuration Customization

Each environment supports extensive customization through variables:

- **VPC Configuration**: CIDR blocks, subnet layout
- **Cluster Settings**: Version, endpoint access, addons
- **Node Groups**: Instance types, scaling, storage
- **Access Control**: IAM users/roles, RBAC

See individual environment `variables.tf` files for detailed options.

## 🔍 Monitoring and Troubleshooting

### Common Issues

1. **OIDC Authentication Failures**
   ```bash
   # Verify OIDC role trust relationship
   aws iam get-role --role-name your-oidc-role
   ```

2. **Terraform State Lock**
   ```bash
   # Force unlock if needed (use carefully)
   cd terraform/aws/overlay/dev/eks
   terraform force-unlock LOCK_ID
   ```

3. **kubectl Access Issues**
   ```bash
   # Update kubeconfig
   aws eks update-kubeconfig --region us-east-2 --name cluster-name
   ```

### Useful Commands

```bash
# Check cluster status
aws eks describe-cluster --name cluster-name --region us-east-2

# View node groups
aws eks describe-nodegroup --cluster-name cluster-name --nodegroup-name nodegroup-name

# Get cluster endpoint
aws eks describe-cluster --name cluster-name --query cluster.endpoint --output text
```

## 🎮 How to Use

### 🔄 Development Workflow (Main Branch Protected)

Since the main branch is protected, all changes must go through pull requests:

**1. Create Feature Branch**
```bash
# Clone the repository (if not already done)
git clone https://github.com/KPDev0ps/aws-eks.git
cd aws-eks

# Create and switch to feature branch
git checkout -b feature/update-dev-config

# Make your changes (e.g., edit terraform/aws/overlay/dev/eks/terraform.tfvars)
# Edit files as needed...

# Commit and push changes
git add .
git commit -m "Update dev cluster configuration"  
git push origin feature/update-dev-config
```

**2. Create Pull Request**
- Go to GitHub and create a PR from your feature branch to `main`
- The **terraform-plan** workflow automatically runs for changed environments
- Review plan output in PR comments
- Get required approvals from team members

**3. Merge and Apply**
- Once approved, merge the PR to main
- The **terraform-apply** workflow automatically runs with environment approval gates
- After successful apply, the source branch is automatically deleted

### 🎯 Manual Workflow Triggers

**Plan-Only (for testing/validation):**
- Go to Actions → "📋 Terraform Plan"
- Click "Run workflow"
- Choose environments: `dev`, `staging`, `prod`, or `all`

**Apply (with plan):**
- Go to Actions → "🚀 Terraform Apply"  
- Click "Run workflow"
- Choose environments and options
- Requires environment approval gates

### 🚨 Important Notes

- **Main branch is protected** - direct pushes are blocked
- **Plan workflow** runs automatically on PRs for changed paths
- **Apply workflow** runs automatically on main branch pushes  
- **Environment approvals** required for apply operations:
  - `dev`: Optional approval (fast iteration)
  - `staging`: 1 required approval
  - `prod`: 2 required approvals + 10-minute wait
- **Source branches** are auto-deleted after successful apply

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

All pull requests will automatically trigger validation workflows.

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🆘 Support

If you encounter any issues:

1. Check the [Issues](https://github.com/KPDev0ps/aws-eks/issues) page
2. Review the troubleshooting section above
3. Create a new issue with detailed information

## 📄 License

This project is licensed under the Mozilla Public License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- HashiCorp for Terraform
- AWS for EKS and related services
- The Kubernetes community
- Contributors and maintainers

---

**Happy Kuberneting!** 🎉
