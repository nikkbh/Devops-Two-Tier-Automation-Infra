# Devops Two-Tier Infra Automation | Azure, Terraform & Ansible

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-blue?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2671E5?logo=github-actions)
![License](https://img.shields.io/badge/License-MIT-green)

A production-ready Infrastructure-as-Code (IaC) project for deploying a two-tier application infrastructure on Microsoft Azure using Terraform and Ansible. This project implements secure OIDC-based authentication with Azure through GitHub Actions for automated CI/CD deployments.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [GitHub Actions Workflow](#github-actions-workflow)
- [OIDC Authentication](#oidc-authentication)
- [Terraform Modules](#terraform-modules)
- [How to Deploy](#how-to-deploy)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

This Infrastructure-as-Code project automates the deployment and configuration of a two-tier application infrastructure on Microsoft Azure. It uses Terraform for infrastructure provisioning and is designed with security-first principles using OpenID Connect (OIDC) federated identity credentials for authentication.

The repository includes two main Terraform deployments:

1. **VNet Deployment** - Creates networking resources (Virtual Network and Subnets)
2. **GitHub Deployment** - Sets up Azure resources for GitHub Actions OIDC authentication and Terraform state management

## Architecture

### Azure Resources Created

The infrastructure creates the following Azure resources:

#### Networking Resources

- **Azure Virtual Network (VNet)**: 10.0.0.0/16 address space
- **Subnet**: 10.0.1.0/24 within the VNet for application tier resources
- **Resource Group**: Logical container for all networking resources

#### OIDC & Security Resources

- **User-Assigned Managed Identity**: For GitHub Actions authentication
- **Federated Identity Credentials**: For both environment-specific and pull request workflows
- **Role Assignments**:
  - Storage Blob Data Contributor (for Terraform state access)
  - Owner role (for subscription-level permissions)

#### State Management Resources

- **Resource Group**: Dedicated for Terraform state infrastructure
- **Azure Storage Account**: Stores Terraform remote state
- **Storage Container**: Holds the tfstate files

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Actions                          │
├─────────────────────────────────────────────────────────────┤
│  On Push/PR → terraform plan                                │
│  On workflow_dispatch → terraform apply                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ OIDC Token
                     ↓
┌─────────────────────────────────────────────────────────────┐
│              Azure Federated Identity                        │
│  (Trust GitHub via OIDC Issuer)                            │
└────────────┬──────────────────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────────────────────┐
│        User-Assigned Managed Identity                        │
│  (Impersonated for Azure Authentication)                   │
└────────────┬──────────────────────────────────────────────┘
             │
             ├─→ Storage Account (tfstate)
             └─→ Subscription (for deployments)
```

## Features

✅ **Security-First Design**

- OpenID Connect (OIDC) federated identity credentials
- No secrets stored in GitHub secrets (only IDs)
- Least privilege role assignments

✅ **Automated CI/CD**

- Automatic `terraform plan` on PRs and push to main
- Manual approval workflow for `terraform apply` via workflow_dispatch
- Terraform plan artifacts stored and published to PRs

✅ **Infrastructure as Code**

- Modular Terraform design with reusable modules
- Clear separation of concerns
- Remote state management in Azure Storage

✅ **Code Quality**

- Terraform format validation
- Policy as Code with tfsec security scanning
- Terraform validation

✅ **Multi-Environment Support**

- Environment-specific variables and tags
- Supports development, staging, and production deployments

## Prerequisites

### Required Tools

- **Terraform**: v1.0 or higher
- **Azure CLI**: Latest version
- **Git**: For repository management
- **GitHub CLI** (optional): For easier management

### Azure Requirements

- **Azure Subscription**: Active subscription with appropriate permissions
- **Azure Tenant**: Access to your Azure Active Directory tenant
- **Service Principal** or **User-Assigned Managed Identity**: For Terraform authentication

### GitHub Requirements

- **GitHub Repository**: Access to the repository where this code is hosted
- **GitHub Actions Enabled**: Workflows must be enabled
- **Repository Secrets**: Required secrets configured (see GitHub Actions Workflow section)

### Permissions

- **Azure Subscription Owner** or **Contributor** role
- **Azure Active Directory** permissions to create identities and role assignments
- **GitHub Actions** workflow permissions enabled

## Directory Structure

```
Devops-Two-Tier-Automation-Infra/
├── README.md                          # This file
├── .github/
│   └── workflows/
│       └── terraform.yaml             # GitHub Actions CI/CD workflow
├── infra/
│   ├── ansible/                       # Configuration management
│   │   ├── configure-vm.yaml          # VM configuration playbook
│   │   └── inventory.ini              # Ansible inventory
│   └── terraform/
│       ├── github-deployment/         # GitHub OIDC setup & state backend
│       │   ├── main.tf                # OIDC resources & storage account
│       │   ├── variables.tf           # Input variables
│       │   ├── locals.tf              # Local values
│       │   ├── providers.tf           # Terraform providers
│       │   ├── terraform.tfvars       # Variable values
│       │   ├── terraform.tfstate      # Current state file
│       │   ├── terraform.tfstate.backup
│       │   ├── tfplan                 # Terraform plan output
│       │   └── tfvars/
│       │       └── terraform.tfvars   # Additional vars
│       ├── vnet-deployment/           # Main application infrastructure
│       │   ├── main.tf                # Resource definitions
│       │   ├── providers.tf           # Azure provider config with OIDC
│       │   ├── variables.tf           # Input variables
│       │   ├── outputs.tf             # Output values
│       │   ├── terraform.tfstate
│       │   ├── terraform.tfstate.backup
│       │   └── tfvars/
│       │       └── terraform.tfvars   # Environment-specific values
│       └── modules/                   # Reusable Terraform modules
│           ├── resource-group/        # Resource Group module
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── output.tf
│           ├── virtual-network/       # VNet module
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── outputs.tf
│           ├── subnet/                # Subnet module
│           │   ├── main.tf
│           │   └── variables.tf
│           ├── user-assigned-identity/
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── output.tf
│           ├── federated-identity-credential/
│           │   ├── main.tf
│           │   └── variables.tf
│           ├── tfstate-storage/       # Storage for Terraform state
│           │   ├── main.tf
│           │   ├── variables.tf
│           │   └── outputs.tf
│           └── role-assignment/       # RBAC role assignments
│               ├── main.tf
│               ├── variables.tf
│               └── output.tf
```

### Key Directories Explained

| Directory                            | Purpose                                                                     |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `infra/terraform/vnet-deployment/`   | Main infrastructure deployment (VNet, Subnets) - this is deployed via CI/CD |
| `infra/terraform/github-deployment/` | One-time setup for GitHub OIDC & state backend - typically run manually     |
| `infra/terraform/modules/`           | Reusable Terraform modules used by both deployments                         |
| `infra/ansible/`                     | Configuration management and VM provisioning playbooks                      |
| `.github/workflows/`                 | GitHub Actions CI/CD pipeline definitions                                   |

## Getting Started

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd Devops-Two-Tier-Automation-Infra
```

### Step 2: Set Up GitHub Secrets

Configure the following secrets in your GitHub repository settings:

**Required Secrets:**

```
AZURE_CLIENT_ID              # Azure Service Principal / App Registration ID
AZURE_SUBSCRIPTION_ID        # Your Azure Subscription ID
AZURE_TENANT_ID              # Your Azure Tenant ID
AZURE_OBJECT_ID              # Object ID of the user or principal

BACKEND_AZURE_RESOURCE_GROUP_NAME      # Resource group for Terraform state
BACKEND_AZURE_STORAGE_ACCOUNT_NAME     # Storage account for tfstate
BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME  # Container name (typically "tfstate")
```

> **Note:** These secrets should be created in your GitHub repository under Settings → Secrets and Variables → Actions

### Step 3: Initialize Azure Environment

#### Option A: Using Azure AD Service Principal (Local Development)

```bash
# Login to Azure
az login

# Create a service principal
az ad sp create-for-rbac --name "tf-devops-sp" --role Contributor \
  --scopes /subscriptions/<subscription-id>

# Note the appId, password, and tenant
```

#### Option B: Using User-Assigned Managed Identity (GitHub Actions)

```bash
# Create a user-assigned managed identity
az identity create --resource-group <rg-name> --name github-oidc-identity

# This identity is created and configured automatically by the github-deployment Terraform module
```

### Step 4: Bootstrap GitHub Deployment (One-Time Setup)

The `github-deployment` configuration must be applied first to set up the OIDC infrastructure:

```bash
cd infra/terraform/github-deployment

# Initialize Terraform
terraform init

# Copy and update the tfvars file
cp terraform.tfvars terraform.tfvars.local

# Edit with your values:
# - github_organization_target
# - github_repository
# - storage_account_name
# - etc.

# Review the plan
terraform plan -var-file="terraform.tfvars.local"

# Apply the configuration
terraform apply -var-file="terraform.tfvars.local"

# Note the outputs (especially the User Assigned Identity ID)
```

### Step 5: Deploy VNet Infrastructure

Once GitHub deployment is complete, deploy the main VNet:

```bash
cd ../vnet-deployment

# Initialize Terraform with your backend
terraform init \
  -backend-config="resource_group_name=<your-backend-rg>" \
  -backend-config="storage_account_name=<your-storage-account>" \
  -backend-config="container_name=tfstate"

# Update variables as needed
vim tfvars/terraform.tfvars

# Plan the deployment
terraform plan -var-file="./tfvars/terraform.tfvars"

# Apply (or trigger via GitHub Actions)
terraform apply -var-file="./tfvars/terraform.tfvars"
```

## GitHub Actions Workflow

### Workflow Overview

The GitHub Actions workflow (`terraform.yaml`) provides automated infrastructure deployment with the following triggers:

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch: # Manual trigger for apply
```

### Workflow Jobs

#### 1. **terraform-plan** (Automatic on PR/Push)

- Triggers on: Pull requests and push to main branch
- **Does NOT run on**: `workflow_dispatch` (manual apply)

**Steps:**

1. ✅ Checkout code
2. 🔐 Azure Login (via OIDC)
3. 🔧 Setup Terraform
4. 📝 Terraform Format Check
5. ⚙️ Terraform Init
6. 🤖 Terraform Validate
7. 🔍 tfsec Security Scan
8. 📊 Terraform Plan
9. 📤 Upload plan as artifact
10. 💬 Post plan summary to PR

#### 2. **terraform-apply** (Manual Trigger)

- Triggers on: `workflow_dispatch` only (manual approval)
- Runs after plan review

**Steps:**

1. ✅ Checkout code
2. 🔐 Azure Login (via OIDC)
3. 🔧 Setup Terraform
4. ⚙️ Terraform Init
5. 📥 Download previous plan
6. ✨ Apply the plan

### Workflow Features

| Feature                 | Description                                           |
| ----------------------- | ----------------------------------------------------- |
| **OIDC Authentication** | No credentials in secrets - uses federated identity   |
| **Auto Plan on PR**     | Automatic review and comment on PRs with plan output  |
| **Artifact Storage**    | Plan files stored as artifacts between plan and apply |
| **Security Scanning**   | tfsec checks for security issues                      |
| **Code Quality**        | Format and validation checks before plan              |
| **PR Comments**         | Detailed plan output posted directly to PRs           |

### Running the Workflow

**Automatic Plan (on PR):**

1. Push a feature branch to trigger a PR
2. Workflow automatically runs `terraform plan`
3. Plan output appears as a PR comment
4. Review the changes

**Manual Apply (after PR merge):**

1. Merge PR to main
2. Go to Actions tab → Select "Deploy Virtual Network & Subnet" workflow
3. Click "Run workflow" → "Run workflow"
4. Workflow downloads the latest plan and applies it
5. Infrastructure is deployed to Azure

## OIDC Authentication

This project uses **OpenID Connect (OIDC)** federated identity credentials for secure Azure authentication without storing long-lived secrets.

### How OIDC Works

```
1. GitHub Actions generates a JWT token
   ↓
2. Token is presented to Azure AD
   ↓
3. Azure AD validates the token against GitHub's issuer
   ↓
4. If valid, Azure grants temporary credentials
   ↓
5. Terraform uses temporary credentials to deploy
```

### OIDC Components

#### 1. **Federated Identity Credential**

```terraform
module "gh_federated_credential" {
  source                             = "../modules/federated-identity-credential"
  subject                            = "repo:github-org/repo-name:environment:dev"
  issuer_url                         = "https://token.actions.githubusercontent.com"
  audience_name                      = "api://AzureADTokenExchange"
}
```

Creates a trust relationship between GitHub Actions and Azure:

- **Subject**: Identifies which GitHub repository/environment can authenticate
- **Issuer**: GitHub's token provider
- **Audience**: Azure AD token exchange endpoint

#### 2. **User-Assigned Managed Identity**

- Acts as the "principal" that GitHub impersonates
- Granted Azure roles (Storage Blob Data Contributor, Owner)
- No passwords or certificates needed

#### 3. **Trust Relationship**

```
GitHub Actions Job → OIDC Token → Federated Credential → User Identity → Azure Role
```

### Security Benefits

✅ **No Long-lived Secrets**: Credentials only exist for the duration of the job  
✅ **Least Privilege**: Fine-grained subject claims (org, repo, environment, branch)  
✅ **Audit Trail**: All OIDC authentications are logged in Azure  
✅ **No Credential Rotation**: Tokens are ephemeral

### Configuring OIDC

The OIDC setup is handled by the `github-deployment` configuration. To customize:

```terraform
# In github-deployment/main.tf

module "gh_federated_credential" {
  subject = "repo:${var.github_organization_target}/${var.github_repository}:environment:${var.environment}"
  # Other parameters...
}
```

**Subject claim options:**

- `repo:org/repo:environment:env-name` - Environment-specific
- `repo:org/repo:pull_request` - For pull request workflows
- `repo:org/repo:branch:main` - For specific branches
- `repo:org/repo:tag:v*` - For release tags

## Terraform Modules

### Module Overview

All modules are located in `infra/terraform/modules/`. Each module is self-contained and reusable.

| Module                          | Purpose                         | Key Resources                                          |
| ------------------------------- | ------------------------------- | ------------------------------------------------------ |
| `resource-group`                | Creates Azure Resource Groups   | `azurerm_resource_group`                               |
| `virtual-network`               | Creates Virtual Networks        | `azurerm_virtual_network`                              |
| `subnet`                        | Creates Subnets within VNets    | `azurerm_subnet`                                       |
| `user-assigned-identity`        | Creates managed identities      | `azurerm_user_assigned_identity`                       |
| `federated-identity-credential` | Sets up OIDC trust              | `azurerm_federated_identity_credential`                |
| `tfstate-storage`               | Manages Terraform state storage | `azurerm_storage_account`, `azurerm_storage_container` |
| `role-assignment`               | Assigns Azure RBAC roles        | `azurerm_role_assignment`                              |

### Module Variables Pattern

Each module follows a standard pattern:

**variables.tf**: Input variables with descriptions  
**main.tf**: Resource definitions  
**output.tf/outputs.tf**: Exported values for other modules

### Module Usage Example

```terraform
module "virtual-network" {
  source    = "../modules/virtual-network"
  rg        = module.resource-group.name
  location  = var.location
  vnet_name = var.vnet_name
}

module "subnet" {
  source      = "../modules/subnet"
  rg          = module.resource-group.name
  vnet_name   = module.virtual-network.vnet_name
  subnet_name = var.subnet_name
}
```

## How to Deploy

### Local Deployment (for testing)

```bash
cd infra/terraform/vnet-deployment

# Initialize Terraform
terraform init \
  -backend-config="resource_group_name=<backend-rg>" \
  -backend-config="storage_account_name=<storage-account>" \
  -backend-config="container_name=tfstate"

# Validate configuration
terraform validate

# Plan changes
terraform plan \
  -var-file="./tfvars/terraform.tfvars" \
  -var="azure_object_id=$(az ad signed-in-user show --query id -o tsv)" \
  -var="client_id=$ARM_CLIENT_ID" \
  -var="tenant_id=$ARM_TENANT_ID" \
  -var="subscription_id=$ARM_SUBSCRIPTION_ID"

# Apply changes
terraform apply -var-file="./tfvars/terraform.tfvars"
```

### GitHub Actions Deployment (recommended)

```bash
# 1. Commit and push changes to a feature branch
git checkout -b feature/update-vnet
# Make changes to terraform files
git add infra/terraform/vnet-deployment/
git commit -m "Update VNet configuration"
git push origin feature/update-vnet

# 2. Create a pull request
# Go to GitHub and create a PR to main

# 3. Review the automatic terraform plan
# GitHub Actions will comment on the PR with the plan output

# 4. Merge the PR
# After approval, merge to main

# 5. Manually trigger apply
# Go to Actions → "Deploy Virtual Network & Subnet" → Run workflow
```

### Troubleshooting Deployments

**Terraform Init Fails:**

```bash
# Check backend configuration
terraform init -reconfigure \
  -backend-config="resource_group_name=<rg>" \
  -backend-config="storage_account_name=<storage>" \
  -backend-config="container_name=tfstate"
```

**State Lock Issues:**

```bash
# Force unlock (use carefully!)
terraform force-unlock <lock-id>
```

**Plan Shows Unexpected Changes:**

```bash
# Refresh state
terraform refresh

# Check current state
terraform state list
terraform state show <resource-address>
```

## Customization

### Modifying Variables

All deployable variables are in `terraform.tfvars` files:

#### VNet Deployment Variables

```hcl
# infra/terraform/vnet-deployment/tfvars/terraform.tfvars

rg          = "rg-vnet"              # Resource group name
vnet_name   = "vnet-two-tier-app"    # Virtual network name
subnet_name = "subnet-two-tier-app"  # Subnet name
location    = "centralindia"         # Azure region

tags = {
  environment = "prod"
  owner       = "nikhil"
  application = "two-tier-app"
  location    = "centralindia"
}
```

#### Common Customizations

**Change Azure Region:**

```hcl
location = "eastus"  # or westeurope, southeastasia, etc.
```

**Update VNet Address Space:**
Edit `infra/terraform/modules/virtual-network/main.tf`:

```hcl
address_space = ["10.0.0.0/16"]  # Change to your CIDR
```

**Change Subnet CIDR:**
Edit `infra/terraform/modules/subnet/main.tf`:

```hcl
address_prefixes = ["10.0.1.0/24"]  # Change as needed
```

**Add More Subnets:**

```terraform
module "subnet-2" {
  source      = "../modules/subnet"
  rg          = module.resource-group.name
  vnet_name   = module.virtual-network.vnet_name
  subnet_name = "subnet-database"
}

module "subnet-3" {
  source      = "../modules/subnet"
  rg          = module.resource-group.name
  vnet_name   = module.virtual-network.vnet_name
  subnet_name = "subnet-management"
}
```

**Modify Tags:**

```hcl
tags = {
  environment = "staging"
  owner       = "your-name"
  application = "your-app"
  costcenter  = "123456"
  managed-by  = "terraform"
}
```

### Adding Resources

To add new resources (e.g., Network Security Group):

1. **Create a new module:**

```bash
mkdir infra/terraform/modules/network-security-group
touch infra/terraform/modules/network-security-group/{main.tf,variables.tf,output.tf}
```

2. **Define the module:**

```terraform
# main.tf
resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location

  security_rule {
    name       = "allow-http"
    priority   = 100
    access     = "Allow"
    direction  = "Inbound"
    protocol   = "Tcp"
    source_port_range      = "*"
    destination_port_range = "80"
    source_address_prefix  = "*"
    destination_address_prefix = "*"
  }
}
```

3. **Use in main.tf:**

```terraform
module "nsg" {
  source   = "../modules/network-security-group"
  name     = "nsg-app"
  rg_name  = module.resource-group.name
  location = var.location
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. **"Error: Failed to get existing workspaces"**

**Cause**: Backend configuration or storage account access issue

**Solution**:

```bash
# Verify storage account exists
az storage account show --name <storage-account-name> --resource-group <rg>

# Check container exists
az storage container list --account-name <storage-account>

# Reconfigure backend
terraform init -reconfigure \
  -backend-config="resource_group_name=<rg>" \
  -backend-config="storage_account_name=<storage>" \
  -backend-config="container_name=tfstate"
```

#### 2. **"Error: Authorization Failed"**

**Cause**: Insufficient permissions or OIDC not properly configured

**Solution**:

```bash
# Check Azure login
az account show

# Verify OIDC setup in github-deployment
terraform -chdir=github-deployment apply -var-file="terraform.tfvars"

# Check role assignments
az role assignment list --assignee <object-id>
```

#### 3. **"Error: Workspace already exists"**

**Cause**: Multiple terraform init calls or state conflict

**Solution**:

```bash
# Check existing workspaces
terraform workspace list

# Select correct workspace
terraform workspace select default

# Force refresh state
terraform refresh -lock=false
```

#### 4. **GitHub Actions: "OIDC token exchange failed"**

**Cause**: Federated credential not properly configured

**Solution**:

```bash
# Verify federated credential
az identity federated-credential list \
  --resource-group <identity-rg> \
  --identity-name <identity-name>

# Reapply github-deployment
cd infra/terraform/github-deployment
terraform apply
```

#### 5. **"Error: Plan file not found"**

**Cause**: Artifact not uploaded or expired

**Solution**:

- Re-run the terraform-plan job
- Check GitHub Actions artifacts (Actions tab → select workflow → Artifacts)
- Artifacts expire after 90 days by default

### Debug Commands

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Check Terraform version
terraform version

# Validate syntax
terraform fmt -check -recursive infra/terraform/

# Validate configuration
terraform validate

# Check state
terraform state list
terraform state show <resource>

# Remove resource from state (use carefully)
terraform state rm <resource>

# Refresh state from Azure
terraform refresh
```

### Getting Help

1. **Check Terraform Logs**: Look at GitHub Actions logs in the Actions tab
2. **Azure Portal**: Verify resources in Azure portal
3. **Azure CLI**: Use Azure CLI to verify resource creation
4. **Terraform Docs**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
5. **GitHub Docs**: https://docs.github.com/en/actions

## Contributing

This project welcomes contributions! Here are guidelines for contributing:

### Before You Start

- Fork the repository
- Create a feature branch: `git checkout -b feature/your-feature`
- Make your changes
- Test locally before pushing

### Code Standards

- **Terraform Code**: Run `terraform fmt` to format code
- **Security**: Run `tfsec` to check for security issues
  ```bash
  tfsec infra/terraform/
  ```
- **Validation**: Run `terraform validate` before committing
  ```bash
  cd infra/terraform/vnet-deployment
  terraform validate
  ```

### Testing Changes

1. **Plan your changes:**

   ```bash
   terraform plan -var-file="./tfvars/terraform.tfvars"
   ```

2. **Create a test resource group:**

   ```bash
   az group create --name test-rg --location centralindia
   ```

3. **Test apply:**

   ```bash
   terraform apply -var-file="./tfvars/terraform.tfvars"
   ```

4. **Destroy after testing:**
   ```bash
   terraform destroy -var-file="./tfvars/terraform.tfvars"
   ```

### Pull Request Process

1. **Update Documentation**: Update README.md if you change functionality
2. **Add Comments**: Document complex terraform code with comments
3. **Test in PR**: Let GitHub Actions run the plan workflow
4. **Request Review**: Request review from project maintainers
5. **Merge**: After approval, merge to main and trigger apply

### Adding Features

**New Module:**

- Create module in `infra/terraform/modules/<new-module>`
- Include variables.tf, main.tf, and output.tf
- Document inputs and outputs
- Test by calling from a deployment configuration

**New Deployment:**

- Create directory in `infra/terraform/<new-deployment>`
- Include main.tf, variables.tf, providers.tf, outputs.tf
- Add corresponding GitHub Actions workflow job if needed

**New Ansible Playbooks:**

- Add to `infra/ansible/`
- Document the playbook purpose
- Test with inventory.ini

### Reporting Issues

If you encounter issues:

1. Check existing issues on GitHub
2. Provide detailed description
3. Include error messages and logs
4. Share terraform plan output (if safe)
5. Include environment details (OS, Terraform version, Azure region)

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support

For support and questions:

- 📧 Create an issue in GitHub
- 📖 Check the documentation above
- 🔗 Review Azure Terraform Provider docs

---

**Last Updated**: February 2026  
**Terraform Version**: 1.0+  
**Azure Provider Version**: 3.0+  
**Status**: ✅ Production Ready
