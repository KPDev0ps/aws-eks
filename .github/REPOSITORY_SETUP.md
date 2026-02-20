# GitHub Repository Configuration Guide

This guide covers the required GitHub repository settings to support the enhanced Terraform workflow with approvals and branch protection.

## 🛡️ Environment Protection Rules

### Required Environments

You need to create the following environments in your GitHub repository:

1. **dev** - For development deployments
2. **staging** - For staging deployments  
3. **prod** - For production deployments

### Setting Up Environment Protection

📍 **Location:** Repository Settings → Environments

#### 1. Create Environments

For each environment (`dev`, `staging`, `prod`):

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Enter environment name (e.g., `dev`, `staging`, `prod`)
4. Click **Configure environment**

#### 2. Configure Protection Rules

**For Development (`dev`):**
- ✅ **Required reviewers:** None (optional: add 1 reviewer for team awareness)
- ⏱️ **Wait timer:** 0 minutes
- 🌿 **Deployment branches:** Selected branches → `main`

**For Staging (`staging`):**
- ✅ **Required reviewers:** 1 reviewer minimum
- ⏱️ **Wait timer:** 0 minutes  
- 🌿 **Deployment branches:** Selected branches → `main`

**For Production (`prod`):**
- ✅ **Required reviewers:** 2 reviewers minimum
- ⏱️ **Wait timer:** 10 minutes (cooling-off period)
- 🌿 **Deployment branches:** Selected branches → `main`
- ✅ **Prevent administrators from bypassing:** Enable

#### 3. Environment Variables (Optional)

Add environment-specific variables if needed:
- `AWS_ACCOUNT_ID` (if different per environment)
- `SLACK_WEBHOOK` (for notifications)

## 🔒 Branch Protection Rules

### Main Branch Protection

📍 **Location:** Repository Settings → Branches → Add rule

#### Required Settings for `main` branch:

```yaml
Branch name pattern: main

Protection rules:
✅ Require a pull request before merging
  ✅ Require approvals (1 minimum)
  ✅ Dismiss stale PR approvals when new commits are pushed
  ✅ Require review from code owners (if using CODEOWNERS)

✅ Require status checks to pass before merging
  ✅ Require branches to be up to date before merging
  Required status checks:
    - terraform-plan (dev)
    - terraform-plan (staging) 
    - terraform-plan (prod)
    - detect-changes

✅ Require conversation resolution before merging
✅ Restrict pushes that create files larger than 100 MB
✅ Do not allow bypassing the above settings
```

#### Optional Advanced Settings:

- ✅ **Require linear history** (prevents merge commits)
- ✅ **Require deployments to succeed** (links to environment deployments)
- ✅ **Lock branch** (if you want to prevent all direct pushes)

## 🚀 Workflow Behavior

### When PR is Created/Updated

1. **Automatic triggers** on paths: `terraform/aws/overlay/**`
2. **Changed directory detection** runs automatically
3. **Plan jobs** execute in parallel for each changed environment
4. **PR comments** show plan output for review
5. **Status checks** must pass before merge is allowed

### When PR is Merged to Main

1. **Automatic apply** triggers for changed environments
2. **Environment approval gates** enforce manual approval:
   - `dev`: Optional approval (immediate if no reviewers)
   - `staging`: 1 required approval
   - `prod`: 2 required approvals + 10-minute wait

### Manual Workflow Dispatch

You can manually trigger workflows with:
- **Environment selection:** `dev`, `staging`, `prod`, or `all`
- **Action choice:** `plan`, `apply`, or `plan-and-apply`
- **Force all environments:** Override change detection

## 👥 Team Permissions

### Recommended Role Setup

**Repository Roles:**
- **Admin:** Lead developers, DevOps team
- **Maintain:** Senior developers
- **Write:** All developers (can create PRs)
- **Read:** Viewers, stakeholders

**Environment Reviewers:**
- **dev:** Any developer with Write access
- **staging:** Senior developers or team leads
- **prod:** DevOps team + lead developers only

## 🔐 Required Secrets

Ensure these secrets are configured in **Settings → Secrets and variables → Actions**:

- `OIDC_ROLE_ARN` - AWS IAM role ARN for OIDC authentication

Optional secrets:
- `SLACK_WEBHOOK` - For deployment notifications
- `INFRACOST_API_KEY` - For cost estimation (if using Infracost)

## 📋 CODEOWNERS File (Optional)

Create `.github/CODEOWNERS` to automatically request reviews:

```bash
# Global owners
* @devops-team

# Terraform infrastructure
terraform/ @devops-team @platform-team

# Production environment (requires additional approval)
terraform/aws/overlay/prod/ @devops-lead @security-team

# GitHub Actions workflows
.github/workflows/ @devops-team
.github/actions/ @devops-team
```

## 🧪 Testing the Setup

### 1. Create a Test PR

1. Create a new branch
2. Make a small change in `terraform/aws/overlay/dev/eks/terraform.tfvars`
3. Create a PR
4. Verify that:
   - Plan job runs automatically
   - Plan output appears in PR comments
   - Status checks are required before merge

### 2. Test Environment Approvals

1. Merge an approved PR to main
2. Verify that:
   - Apply job waits for environment approval
   - Correct number of approvals required per environment
   - Apply proceeds after approval

### 3. Test Branch Protection

1. Try to push directly to main (should be blocked)
2. Try to merge PR without approvals (should be blocked)
3. Try to merge PR with failing status checks (should be blocked)

## 🛠️ Commands for Repository Admins

### Enable Branch Protection via GitHub CLI

```bash
# Install GitHub CLI if not already installed
# https://cli.github.com/

# Set branch protection for main
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["detect-changes","terraform-plan (dev)","terraform-plan (staging)","terraform-plan (prod)"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null
```

### Create Environments via GitHub CLI

```bash
# Create dev environment
gh api repos/{owner}/{repo}/environments/dev --method PUT

# Create staging environment with 1 reviewer
gh api repos/{owner}/{repo}/environments/staging --method PUT \
  --field reviewers='[{"type":"User","id":USER_ID}]'

# Create prod environment with 2 reviewers and wait timer
gh api repos/{owner}/{repo}/environments/prod --method PUT \
  --field reviewers='[{"type":"User","id":USER1_ID},{"type":"User","id":USER2_ID}]' \
  --field wait_timer=10
```

## 📚 Additional Resources

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [GitHub OIDC with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [Terraform GitHub Actions](https://learn.hashicorp.com/tutorials/terraform/github-actions)