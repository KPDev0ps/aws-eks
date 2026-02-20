# AWS EKS Terraform Automation

[![Terraform Validation](https://github.com/KPDev0ps/aws-eks/actions/workflows/terraform-validation.yml/badge.svg)](https://github.com/KPDev0ps/aws-eks/actions/workflows/terraform-validation.yml)

A complete, production-ready solution for deploying Amazon EKS clusters using Terraform and GitHub Actions. This repository provides a standardized approach to EKS deployment across multiple environments (dev, staging, production) with **fully automated CI/CD pipelines** that include approval gates.

## ⚡ Quick Start

### For Developers

```bash
# 1. Create feature branch
git checkout -b feature/my-changes

# 2. Make terraform changes
edit terraform/aws/overlay/dev/eks/terraform.tfvars

# 3. Commit and push
git add . && git commit -m "Update config" && git push origin feature/my-changes

# 4. Create PR
# → Plan runs automatically ✅
# → Review plan output in PR comments
# → Get PR approval and merge

# 5. After merge to main
# → Apply workflow starts automatically ✅
# → Waits for environment approval ⏳
# → Designated approver approves ✅
# → Infrastructure updated ✅
```

### For Approvers

When you receive an approval notification:

1. Go to **Actions** tab → Click the pending workflow run
2. **Review the plan output** from the "Plan" job (already completed)
3. Click **"Review deployments"** button on the "Apply" job
4. Review the environment and changes
5. Click **"Approve and deploy"** (or Reject)
6. Apply runs automatically with the exact plan you reviewed

### Workflow Run Names

Workflows now have descriptive, unique run names for easy identification:

**Plan Workflow:**
- Format: `📋 Plan #123 - pull_request - @username`
- Shows: Run number, event type (pull_request/workflow_dispatch), who triggered it

**Apply Workflow:**
- Format: `🚀 Apply #456 - push - @username`
- Shows: Run number, event type (push/workflow_dispatch), who triggered it

This makes it easy to identify and track workflow runs in the Actions tab.

### Workflow Behavior

| Trigger | When | What Happens | Approval Needed? |
|---------|------|--------------|------------------|
| **Create/Update PR** | Any terraform path change | Plan runs immediately, posts results to PR | ❌ No |
| **Merge to Main** | PR merged with terraform changes | Plan runs first, then Apply waits for approval | ✅ Yes (per environment) |

**PR Events that Trigger Plan:**
- `opened` - When a new **non-draft** PR is created
- `synchronize` - When new commits are pushed to a **non-draft** PR  
- `reopened` - When a closed **non-draft** PR is reopened
- `ready_for_review` - When a draft PR is marked ready for review

**Important:** 
- Plan workflow is **completely skipped** for draft PRs - the workflow won't even start
- Validation runs separately in `terraform-validation.yml` - both workflows run in parallel
- Mark your PR as "Ready for review" to trigger both validation and plan workflows

**Approval Requirements:**
- **Dev**: Optional (immediate or 1 approval)
- **Staging**: 1 approval required
- **Prod**: 2 approvals + 10-minute wait

## 🚀 Features

- **Multi-Environment Support**: Separate configurations for dev, staging, and production
- **AWS Predefined Modules**: Uses official AWS Terraform modules for reliability and best practices
- **Automated CI/CD Pipeline**: 
  - ✅ **Automatic Plan on PR** - Runs immediately when PR is created
  - ✅ **Automatic Apply on Merge** - Triggers when PR merges to main
  - ✅ **Approval Required** - Environment-based approval gates before apply
- **Path-Based Triggers**: Workflows run only when terraform files change
- **Security-First**: OIDC authentication, encrypted storage, security scanning
- **Cost Optimized**: Environment-specific resource sizing
- **Production Ready**: High availability, monitoring, and best practices

## 📊 Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AUTOMATED CI/CD FLOW                         │
└─────────────────────────────────────────────────────────────────────┘

1️⃣ Developer Creates/Updates PR (Non-Draft)
   │
   ├─→ If PR is DRAFT: Entire workflow skipped ⏭️ (to save resources)
   ├─→ If PR is READY: Two workflows trigger in parallel ⚡
   │
   ├─→ Workflow 1: terraform-validation.yml (separate workflow)
   │   ├─ Code Quality & Format validation
   │   ├─ Environment syntax validation
   │   └─ Security scanning (runs independently)
   │
   ├─→ Workflow 2: terraform-plan.yml ✅
   │   ├─ Detects which environments changed
   │   ├─ Runs terraform plan for changed envs
   │   └─ Posts results as PR comment
   │
   └─→ PR Review Process
       ├─ Team reviews validation results
       ├─ Team reviews plan output
       ├─ Code review approval (1 required)
       └─ Merge to main

2️⃣ PR Merged to Main  
   │
   └─→ terraform-apply.yml triggers AUTOMATICALLY ✅
       │
       ├─ Step 1: Plan Job (No Approval Needed)
       │   ├─ Detects changed environments
       │   ├─ Runs terraform plan
       │   ├─ Uploads plan artifact
       │   └─✅ Completes
       │
       └─ Step 2: Apply Job (Approval Required) ⏳
           │
           ├─ [DEV] Approval: Optional/Immediate
           │   ├─ Downloads plan artifact
           │   └─→ Terraform apply runs ✅
           │
           ├─ [STAGING] Approval: 1 Reviewer Required
           │   ├─ Workflow PAUSES ⏳
           │   ├─ Reviewer sees plan from Step 1
           │   ├─ Reviewer clicks "Approve deployment" ✅
           │   ├─ Downloads plan artifact
           │   └─→ Terraform apply runs ✅
           │
           └─ [PROD] Approval: 2 Reviewers + 10min Wait
               ├─ Workflow PAUSES ⏳
               ├─ Reviewers see plan from Step 1
               ├─ Both reviewers approve ✅
               ├─ Wait 10 minutes ⏱️
               ├─ Downloads plan artifact
               └─→ Terraform apply runs ✅

3️⃣ Post-Apply Actions
   │
   ├─→ Infrastructure updated in AWS
   ├─→ Summary posted to workflow run
   └─→ Source branch auto-deleted
```

### 🔐 How Approvals Work

**Improved Two-Step Process:**

**Step 1: Plan (Automatic, No Approval)**
- Runs immediately after PR merge
- Executes terraform plan
- Shows what will change
- Uploads plan artifact
- No approval needed (read-only)

**Step 2: Apply (Requires Approval)**
- Pauses and waits for approval
- Approver can review the plan from Step 1
- After approval, downloads the plan artifact
- Executes terraform apply with approved plan

**What Happens When Apply Needs Approval:**

1. **Plan Completes First:**
   - Terraform plan runs and completes
   - Plan output visible in workflow summary
   - Plan artifact saved for apply step

2. **Apply Job Pauses:**
   - Apply job shows "Waiting for approval" status
   - Job does not proceed until approved
   - Plan is already visible for review

3. **Approvers Notified:**
   - Designated approvers receive GitHub notification
   - Email notification sent (if enabled)
   - Approvers can see:
     - Plan output from previous job
     - Which environment needs approval
     - Pending deployment in Actions tab

4. **Approval Process:**
   - Approver navigates to: Actions → Workflow Run
   - Reviews the plan output from Step 1
   - Clicks "Review deployments" button
   - Sees deployment details and environment
   - Clicks "Approve and deploy" or "Reject"
   - Optional: Add comment explaining decision

5. **After Approval:**
   - Workflow resumes automatically
   - Downloads the approved plan
   - Apply step executes with the exact plan
   - Infrastructure updated
   - Approvers notified of completion

6. **After Rejection:**
   - Workflow fails (apply job cancelled)
   - No infrastructure changes made
   - Team notified of rejection
   - Can re-run workflow manually if needed

**Who Can Approve:**
- Only designated reviewers for each environment
- Configured in: Settings → Environments → [env] → Required reviewers
- Approvers should be experienced with infrastructure changes
- Recommend: DevOps team, senior developers, platform engineers

**Best Practices:**
- ✅ Review the plan output before approving
- ✅ Check the apply won't cause downtime
- ✅ Verify changes match the PR description
- ✅ Confirm it's safe to proceed
- ✅ Add approval comment explaining what was reviewed
- ❌ Don't approve blindly
- ❌ Don't approve without reviewing plan
- ❌ Don't rush production approvals

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
- **Path-based triggers** on `terraform/**` changes (any terraform file)
- **Immediate execution** - plan runs automatically when PR is created or updated

### 🛡️ Approval Gates & Protection
- **Separate plan/apply workflows** for clear separation of concerns
- **Environment-based approval requirements** for apply operations (enforced by GitHub Environments)
- **Branch protection** requires PR approval and status checks before merge
- **Apply requires approval** - after PR merge to main, the apply workflow waits for environment-specific approvals
- **Environment protection rules**:
  - `dev`: Optional approval (can proceed immediately for fast iteration)
  - `staging`: 1 required approval before apply
  - `prod`: 2 required approvals + 10-minute cooling period before apply

### 📋 Workflow Triggers

#### Plan Workflow (`terraform-plan.yml`)
- **Pull Requests → Main**: 
  - ✅ **Triggers immediately** on PR events: `opened`, `synchronize`, `reopened`, `ready_for_review`
  - ✅ **Draft PRs completely excluded** - workflow won't start at all for draft PRs
  - ✅ Runs on **any change** to `terraform/**` paths
  - ✅ **Workflow steps**:
    - Step 1: Detect changes in terraform directories
    - Step 2: Terraform plan (changed environments only)
    - Step 3: Post results to PR comments
  - ✅ Runs **in parallel** with terraform-validation.yml
  - ✅ Automatically detects which environments are affected
  - ✅ Posts plan output as PR comment
  - ✅ Updates comment on subsequent commits (non-draft only)
- **Manual dispatch**: Target specific environments with plan-only
- **PR Integration**: Plan outputs commented directly on PRs
- **Status checks**: Required to pass before PR merge
- **No approval needed**: Plan is read-only, safe to run automatically
- **Unique run names**: Shows run number, event type, and triggering user

**Note:** Code validation runs separately in `terraform-validation.yml` workflow. Both workflows run in parallel for faster feedback.

#### Apply Workflow (`terraform-apply.yml`)  
- **Main Branch Push**: 
  - ✅ **Triggers automatically** when PR is merged to main
  - ✅ Runs on **any change** to `terraform/**` paths
  - ✅ **Two-phase execution**:
    - Phase 1: Plan job (no approval, generates plan)
    - Phase 2: Apply job (requires approval, applies plan)
  - ✅ **Approval happens between plan and apply**
  - ✅ Workflow pauses and waits for required approvers
  - ✅ Only proceeds after approval is granted
- **Manual dispatch**: Target specific environments with plan+apply
- **Auto cleanup**: Source branch deleted automatically after successful apply
- **Environment gates**: Enforced approval requirements before apply
- **Unique run names**: Shows commit message, SHA, and triggering user
- **Approval Process**:
  1. PR is merged to main → Apply workflow starts
  2. Plan job runs (no approval needed)
  3. Plan output visible in workflow summary
  4. Apply job waits for approval
  5. Approver reviews plan and approves
  6. Apply executes with approved plan
  7. Infrastructure updated

### 💬 PR Integration
- **Plan output** automatically commented on pull requests
- **Status checks** prevent merging without successful plans
- **Change summaries** show which environments will be affected
- **Updated comments** replace previous plan results for same environment

## 📚 Repository Configuration

**Important**: Before using the workflows, you must configure GitHub repository settings for branch protection and environment approvals.
### 🔐 Required Setup (One-Time Configuration)

#### 1. Create GitHub Environments

The workflows require three environments with protection rules:

**Navigate to:** Repository → Settings → Environments → "New environment"

**Create these environments:**

| Environment | Required Approvals | Wait Timer | Deployment Branches |
|-------------|-------------------|------------|---------------------|
| **dev** | 0-1 (optional) | 0 minutes | `main` only |
| **staging** | 1 | 0 minutes | `main` only |
| **prod** | 2 | 10 minutes | `main` only |

**Step-by-step:**

1. **Create `dev` Environment:**
   - Click "New environment" → Name: `dev`
   - Configure environment:
     - ☐ Required reviewers: (leave empty or add 1 for awareness)
     - ☐ Wait timer: 0 minutes
     - ☑ Deployment branches: Selected branches → Add `main`
   - Click "Save protection rules"

2. **Create `staging` Environment:**
   - Click "New environment" → Name: `staging`
   - Configure environment:
     - ☑ Required reviewers: Select 1 team member
     - ☐ Wait timer: 0 minutes
     - ☑ Deployment branches: Selected branches → Add `main`
   - Click "Save protection rules"

3. **Create `prod` Environment:**
   - Click "New environment" → Name: `prod`
   - Configure environment:
     - ☑ Required reviewers: Select 2 team members (senior devs/DevOps)
     - ☑ Wait timer: 10 minutes
     - ☑ Deployment branches: Selected branches → Add `main`
     - ☑ Prevent administrators from bypassing: Enable
   - Click "Save protection rules"

#### 2. Configure Branch Protection

**Navigate to:** Repository → Settings → Branches → "Add rule"

**Branch name pattern:** `main`

**Enable these rules:**
- ☑ Require a pull request before merging
  - ☑ Require approvals: 1 minimum
  - ☑ Dismiss stale PR approvals when new commits are pushed
- ☑ Require status checks to pass before merging
  - ☑ Require branches to be up to date before merging
  - Add required status checks:
    - `detect-changes`
    - `terraform-plan (dev)`
    - `terraform-plan (staging)`
    - `terraform-plan (prod)`
- ☑ Require conversation resolution before merging
- ☑ Do not allow bypassing the above settings

#### 3. Add GitHub Secrets

**Navigate to:** Repository → Settings → Secrets and variables → Actions

**Required secret:**
- Name: `OIDC_ROLE_ARN`
- Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-eks-deploy`
  - (Use the role ARN created in OIDC setup)

### ✅ Verify Configuration

**Test the setup:**
1. Create a test branch and PR with a small terraform change
2. Verify plan runs automatically on PR
3. Merge the PR
4. Verify apply workflow pauses for approval
5. Approve the deployment
6. Verify apply completes successfully
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

Set up OIDC trust relationship between GitHub and AWS for secure, keyless authentication:

##### Step 1: Create OIDC Identity Provider in AWS

1. **Navigate to IAM Console:**
   - Go to AWS Console → IAM → Identity providers → Add provider

2. **Configure Provider:**
   - **Provider type:** OpenID Connect
   - **Provider URL:** `https://token.actions.githubusercontent.com`
   - **Audience:** `sts.amazonaws.com`
   - Click "Get thumbprint" (AWS will auto-fetch)
   - Click "Add provider"

**Using AWS CLI:**
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

##### Step 2: Create IAM Role for GitHub Actions

1. **Create IAM Role:**
   - Go to IAM → Roles → Create role
   - Select "Web identity"
   - **Identity provider:** token.actions.githubusercontent.com
   - **Audience:** sts.amazonaws.com
   - Click "Next"

2. **Attach Permissions:**
   
   Attach these AWS managed policies:
   - `AmazonEKSClusterPolicy`
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEC2ContainerRegistryReadOnly`
   - `AmazonVPCFullAccess` (or create custom policy with least privilege)
   
   **Custom Policy for Terraform State (Required):**
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "s3:GetObject",
           "s3:PutObject",
           "s3:DeleteObject",
           "s3:ListBucket"
         ],
         "Resource": [
           "arn:aws:s3:::your-terraform-state-bucket",
           "arn:aws:s3:::your-terraform-state-bucket/*"
         ]
       },
       {
         "Effect": "Allow",
         "Action": [
           "dynamodb:GetItem",
           "dynamodb:PutItem",
           "dynamodb:DeleteItem"
         ],
         "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
       }
     ]
   }
   ```

3. **Name the Role:**
   - Role name: `github-actions-eks-deploy`
   - Description: "GitHub Actions role for EKS Terraform deployments"
   - Click "Create role"

##### Step 3: Configure Trust Policy

**Edit the trust policy** of the created role to restrict access to your repository:

1. Go to the role → Trust relationships → Edit trust policy
2. Replace with:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

**For stricter security** (only allow from main branch or specific environments):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:YOUR_GITHUB_ORG/YOUR_REPO:ref:refs/heads/main",
            "repo:YOUR_GITHUB_ORG/YOUR_REPO:pull_request",
            "repo:YOUR_GITHUB_ORG/YOUR_REPO:environment:dev",
            "repo:YOUR_GITHUB_ORG/YOUR_REPO:environment:staging",
            "repo:YOUR_GITHUB_ORG/YOUR_REPO:environment:prod"
          ]
        }
      }
    }
  ]
}
```

##### Step 4: Add Role ARN to GitHub Secrets

1. Copy the Role ARN from the IAM role summary page
   - Format: `arn:aws:iam::123456789012:role/github-actions-eks-deploy`

2. In your GitHub repository:
   - Go to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `OIDC_ROLE_ARN`
   - Value: (paste the role ARN)
   - Click "Add secret"

##### Step 5: Verify OIDC Configuration

**Test the OIDC authentication:**

Create a test workflow or use the existing `terraform-validation.yml`:

```yaml
- name: 🛡️ Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.OIDC_ROLE_ARN }}
    aws-region: us-east-2
    role-duration-seconds: 3600

- name: 🧪 Test AWS Access
  run: |
    aws sts get-caller-identity
    echo "✅ OIDC authentication successful!"
```

**Using AWS CLI to verify OIDC provider:**
```bash
# List OIDC providers
aws iam list-open-id-connect-providers

# Get OIDC provider details
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com
```

##### Step 6: Create Terraform State Backend

Before running Terraform, set up the S3 backend:

```bash
# Create S3 bucket for state
aws s3 mb s3://your-terraform-state-bucket --region us-east-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration \
  '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket your-terraform-state-bucket \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-2
```

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

### Workflow Troubleshooting

**Plan workflow not running on PR?**

Check these common issues:

1. **Draft PR**: Plan workflow is completely skipped for draft PRs
   - Solution: Click "Ready for review" button to convert from draft
   - This is intentional to prevent unnecessary runs during development
   - The workflow won't even start for draft PRs

2. **Wrong paths changed**: Workflow only triggers on `terraform/**` paths
   - Solution: Ensure your changes are in terraform directories
   - Check the `paths:` filter in the workflow file

3. **Wrong target branch**: Workflow only triggers for PRs to `main` branch
   - Solution: Ensure your PR targets the main branch

4. **Workflow permissions**: Check repository Actions permissions
   - Navigate to: Settings → Actions → General
   - Ensure "Allow all actions" or at least allow actions from GitHub

5. **Check workflow logs**: Go to Actions tab to see if workflow started but failed
   - Look for error messages in the workflow run
   - Check if detect-changes job completed successfully

**Note:** The `terraform-validation.yml` workflow runs separately and in parallel. Even if validation fails, the plan workflow will still run. Both workflows provide feedback independently.

4. **Branch protection not configured**: May need to manually trigger
   - Solution: Set up branch protection rules (see Repository Configuration section)

5. **Workflow permissions**: Check repository Actions permissions
   - Navigate to: Settings → Actions → General
   - Ensure "Allow all actions" or at least allow actions from GitHub

**Apply workflow not waiting for approval?**

1. **Environment not configured**: Check environment protection rules
   - Navigate to: Settings → Environments → [dev/staging/prod]
   - Ensure "Required reviewers" is configured

2. **Check job sequence**: Verify apply job comes after plan job
   - Look for: "Plan" job completes → "Apply" job waits for approval

**Run name not showing correctly?**

- Plan workflow: Should show PR number and title
- Apply workflow: Should show commit message and SHA
- If not showing: Check if triggered by supported event (PR, push, manual)

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

### 🔄 Standard Development Workflow

The repository is configured with a **fully automated CI/CD pipeline** that:
- ✅ Runs Terraform **plan** immediately when you create a PR
- ✅ Runs Terraform **apply** automatically when PR is merged to main
- ✅ **Requires approval** before apply (based on environment)
- ✅ Ensures infrastructure changes are reviewed and approved

#### Step-by-Step Process:

**1. Create Feature Branch & Make Changes**
```bash
# Clone the repository (if not already done)
git clone https://github.com/KPDev0ps/aws-eks.git
cd aws-eks

# Create and switch to feature branch
git checkout -b feature/update-dev-cluster

# Make your changes
# Example: Edit terraform/aws/overlay/dev/eks/terraform.tfvars
nano terraform/aws/overlay/dev/eks/terraform.tfvars

# Commit and push changes
git add .
git commit -m "Update dev cluster node count"  
git push origin feature/update-dev-cluster
```

**2. Create Pull Request**
- Go to GitHub and create a PR from your feature branch to `main`
- **Automatic actions:**
  - ✅ `terraform-plan` workflow **runs immediately** (within seconds)
  - ✅ Plan analyzes which environments are affected
  - ✅ Plan results posted as PR comment
  - ✅ Status check added to PR (must pass before merge)

**3. Review Plan Output**
- Review the plan output in the PR comments
- Check what resources will be created/modified/destroyed
- Request code review from team members
- Get required PR approvals (1 approval minimum for main branch)

**4. Merge to Main**
- Once approved and all checks pass, merge the PR
- GitHub merges the PR to main branch
- Source feature branch can be deleted

**5. Automatic Apply with Approval Gates** ⭐
- **Immediately after merge:**
  - ✅ `terraform-apply` workflow **starts automatically**
  - ✅ Workflow detects which environments changed
  - ✅ Workflow **pauses** at the apply step
  - ✅ **Waits for environment approval** before proceeding

- **Approval Process:**
  
  **For Dev Environment:**
  - Optional approval (can be configured to proceed immediately)
  - Or requires 1 approval from any team member
  
  **For Staging Environment:**
  - **Required:** 1 approval from designated reviewers
  - Workflow shows "Waiting for approval" status
  - Designated approvers receive notification
  - Approver clicks "Review deployments" → "Approve deployment"
  - Apply proceeds automatically after approval
  
  **For Production Environment:**
  - **Required:** 2 approvals from designated reviewers
  - **Required:** 10-minute cooling-off period (minimum wait time)
  - Both approvals + wait time must be satisfied
  - Apply proceeds only after all conditions met

- **After Approval:**
  - ✅ Terraform apply executes
  - ✅ Infrastructure is updated
  - ✅ Summary posted to workflow run
  - ✅ Source branch automatically deleted
  - ✅ Notification sent (if configured)

**6. Verify Deployment**
```bash
# Connect to updated cluster
aws eks update-kubeconfig --region us-east-2 --name dev-eks-cluster

# Verify nodes
kubectl get nodes

# Check cluster health
kubectl get pods --all-namespaces
```

### 🎯 Example: Updating Dev Environment Node Count

```bash
# 1. Create branch
git checkout -b update-dev-nodes

# 2. Edit configuration
cat >> terraform/aws/overlay/dev/eks/terraform.tfvars << EOF
# Update min/max node count
eks_managed_node_groups = {
  general = {
    min_size     = 2  # Changed from 1
    max_size     = 5  # Changed from 3
    desired_size = 2
  }
}
EOF

# 3. Commit and push
git add terraform/aws/overlay/dev/eks/terraform.tfvars
git commit -m "Increase dev cluster min nodes to 2"
git push origin update-dev-nodes

# 4. Create PR on GitHub
# - Plan runs automatically ✅
# - Review plan output in PR comments
# - Get approval from team

# 5. Merge PR
# - Apply workflow starts automatically ✅
# - Waits for environment approval ⏳
# - Designated approver approves ✅
# - Infrastructure updated automatically ✅
```

### 🔄 Development Workflow (Main Branch Protected)

**Important:** Direct pushes to main are blocked. All changes require a pull request.

**Quick Reference:**
1. **Branch** → Make changes → Commit → Push
2. **PR Created** → Plan runs automatically ✅
3. **Review** → Get approvals → Merge
4. **Merged** → Apply waits for environment approval ⏳
5. **Approve** → Infrastructure updated ✅

### 🎯 Manual Workflow Triggers (Advanced)

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
