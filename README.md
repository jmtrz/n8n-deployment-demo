# n8n Azure Deployment with Terraform

This project provides automated deployment of n8n (workflow automation platform) to Azure App Service using Terraform and GitHub Actions.

## 🏗️ Architecture

- **Azure Resource Group**: Container for all resources
- **Azure App Service Plan**: Linux-based hosting plan (Basic B1)
- **Azure App Service**: Containerized n8n application
- **Docker Container**: Official n8n Docker image from `docker.n8n.io/n8nio/n8n`

## 📋 Prerequisites

### Required Tools
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
- GitHub account with repository
- Azure subscription

### Azure Permissions
- Contributor role on your Azure subscription
- Ability to create service principals

## 🚀 Quick Start

### 1. Azure Service Principal Setup

First, create a service principal for GitHub Actions authentication:

```bash
# Login to Azure
az login

# Create service principal (replace with your subscription ID)
az ad sp create-for-rbac \
    --name "github-actions-terraform" \
    --role Contributor \
    --scopes /subscriptions/YOUR_SUBSCRIPTION_ID \
    --sdk-auth
```

This will output JSON with the credentials you need for GitHub secrets.

### 2. GitHub Secrets Configuration

Add these secrets to your GitHub repository (`Settings` → `Secrets and variables` → `Actions`):

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `ARM_CLIENT_ID` | Service principal app ID | `12345678-1234-1234-1234-123456789abc` |
| `ARM_CLIENT_SECRET` | Service principal password | `your-secret-password` |
| `ARM_SUBSCRIPTION_ID` | Your Azure subscription ID | `0b1194e2-addf-4aa2-b22c-0d4c58fa1720` |
| `ARM_TENANT_ID` | Your Azure tenant ID | `87654321-4321-4321-4321-cba987654321` |
| `TF_VAR_n8n_admin_password` | n8n admin password | `your-secure-password` |

### 3. Deploy to Azure

1. **Plan Deployment**:
   - Go to `Actions` tab in your GitHub repository
   - Run `🗒️ Terraform Plan` workflow
   - Review the execution plan

2. **Apply Deployment**:
   - Run `🚀 Terraform Apply` workflow
   - Wait for deployment to complete

## 🔧 Configuration

### n8n Settings

The deployment configures n8n with the following settings:

- **Basic Authentication**: Enabled (admin/your-password)
- **HTTPS**: Enforced
- **Port**: 5678 (internal)
- **Host**: 0.0.0.0
- **Storage**: App Service storage enabled

### Terraform Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `n8n_admin_password` | Admin password for n8n | - | Yes |

### Customization

To modify the deployment:

1. **Resource Names**: Edit `terraform/main.tf`
2. **App Service Plan**: Change SKU in `azurerm_app_service_plan`
3. **n8n Configuration**: Modify `app_settings` in `azurerm_app_service`
4. **Location**: Update `location` in `azurerm_resource_group`

## 📁 Project Structure

```
├── .github/
│   └── workflows/
│       ├── n8n-plan.yaml      # Terraform plan workflow
│       └── n8n-apply.yaml     # Terraform apply workflow
├── terraform/
│   ├── main.tf                # Main Terraform configuration
│   ├── providers.tf           # Provider and backend configuration
│   └── variables.tf           # Variable definitions
├── az-commands.sh             # Service principal creation script
└── README.md                  # This file
```

## 🔄 GitHub Actions Workflows

### Terraform Plan (`n8n-plan.yaml`)
- **Trigger**: Manual (`workflow_dispatch`)
- **Purpose**: Preview changes before deployment
- **Steps**: Init → Format Check → Validate → Plan

### Terraform Apply (`n8n-apply.yaml`)
- **Trigger**: Manual (`workflow_dispatch`)
- **Purpose**: Deploy infrastructure to Azure
- **Steps**: Init → Format Check → Validate → Apply

Both workflows use:
- Ubuntu latest runner
- Terraform 1.5.0
- Service principal authentication
- Working directory: `./terraform`

## 🔒 Security Features

- **No hardcoded secrets** in code
- **GitHub secret scanning** protection
- **Service principal** authentication
- **HTTPS enforcement** on App Service
- **Sensitive variables** marked in Terraform

## 🌐 Accessing n8n

After successful deployment:

1. Find your App Service URL in the Azure portal
2. Navigate to `https://your-app-name.azurewebsites.net`
3. Login with:
   - **Username**: admin
   - **Password**: [your configured password]

## 🛠️ Troubleshooting

### Common Issues

1. **GitHub Push Protection Error**:
   - Remove any hardcoded secrets from files
   - Use the GitHub security URL to allow legitimate secrets

2. **Terraform Authentication Error**:
   - Verify all ARM_* secrets are correctly set
   - Ensure service principal has Contributor role

3. **App Service Deployment Fails**:
   - Check App Service logs in Azure portal
   - Verify Docker image availability

### Useful Commands

```bash
# Check Terraform formatting
terraform fmt -check

# Validate Terraform configuration
terraform validate

# Plan deployment locally
terraform plan

# Check Azure CLI login
az account show
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)