# Terraform Backend Setup with GitHub Actions

This guide explains how to set up Terraform backend storage using GitHub Actions, replacing the manual `create-backend.sh` script.

## Overview

The Terraform backend setup has been automated using GitHub Actions and Terraform itself. The system will:

1. **Check if backend exists**: Automatically detect if backend resources are already configured
2. **Create backend if needed**: Use Terraform to create Azure storage resources
3. **Configure main pipeline**: Ensure the main deployment pipeline uses the created backend

## Quick Start

### Step 1: Configure Azure Credentials

Ensure these secrets are configured in your GitHub repository:

```
ARM_CLIENT_ID=<your-service-principal-client-id>
ARM_CLIENT_SECRET=<your-service-principal-client-secret>
ARM_SUBSCRIPTION_ID=<your-azure-subscription-id>
ARM_TENANT_ID=<your-azure-tenant-id>
```

### Step 2: Run Backend Setup

1. Go to **Actions** tab in your GitHub repository
2. Select **"Setup Terraform Backend"** workflow
3. Click **"Run workflow"**
4. The workflow will create the backend resources if they don't exist

### Step 3: Configure Backend Secrets

After the workflow completes, add the backend access key to your secrets:

1. Copy the `TF_BACKEND_ACCESS_KEY` value from the workflow output
2. Add it as a repository secret with the name `TF_BACKEND_ACCESS_KEY`

The other backend secrets (`TF_BACKEND_RESOURCE_GROUP_NAME`, `TF_BACKEND_STORAGE_ACCOUNT_NAME`, `TF_BACKEND_CONTAINER_NAME`) need to be added manually based on the workflow output.

### Step 4: Deploy Your Infrastructure

After the backend is configured, your normal deployment workflows will automatically use the remote backend.

## Architecture

### Backend Resources Created

```
Azure Resource Group: n8n-terraform-state-rg
├── Storage Account: n8ntfstate<random-suffix>
    └── Blob Container: tfstate
        ├── main/terraform.tfstate (main infrastructure)
        └── static-web-app/terraform.tfstate (static web app)
```

### Workflow Integration

1. **Setup Terraform Backend** (`setup-terraform-backend.yml`)
   - Creates backend resources using Terraform
   - Outputs configuration for GitHub secrets
   - Runs on-demand or when backend config changes

2. **Deploy Static Web App** (`deploy-static-web-app.yml`)
   - Checks backend configuration before running
   - Uses remote backend for state storage
   - Deploys main infrastructure and static web app

## Configuration

### Backend Module Variables

The backend Terraform module accepts these variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `resource_group_name` | Resource group for backend | `n8n-terraform-state-rg` |
| `location` | Azure region | `West US 2` |
| `storage_account_prefix` | Storage account prefix | `n8ntfstate` |
| `container_name` | Blob container name | `tfstate` |
| `environment` | Environment tag | `demo` |

### Required GitHub Secrets

| Secret | Description | Source |
|--------|-------------|--------|
| `ARM_CLIENT_ID` | Azure service principal ID | Your Azure setup |
| `ARM_CLIENT_SECRET` | Azure service principal secret | Your Azure setup |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID | Your Azure setup |
| `ARM_TENANT_ID` | Azure tenant ID | Your Azure setup |
| `TF_BACKEND_RESOURCE_GROUP_NAME` | Backend resource group | Workflow output |
| `TF_BACKEND_STORAGE_ACCOUNT_NAME` | Backend storage account | Workflow output |
| `TF_BACKEND_CONTAINER_NAME` | Backend container name | Workflow output |
| `TF_BACKEND_ACCESS_KEY` | Storage account access key | Workflow output |

## Migration from create-backend.sh

If you previously used the `create-backend.sh` script:

### Option 1: Use Existing Resources

If you have existing backend resources:

1. Add the existing configuration to GitHub secrets:
   ```
   TF_BACKEND_RESOURCE_GROUP_NAME=<existing-rg-name>
   TF_BACKEND_STORAGE_ACCOUNT_NAME=<existing-storage-name>
   TF_BACKEND_CONTAINER_NAME=<existing-container-name>
   TF_BACKEND_ACCESS_KEY=<existing-access-key>
   ```

2. The workflows will automatically use the existing backend

### Option 2: Migrate to New Setup

1. **Backup existing state** (if any):
   ```bash
   # Download current state files
   az storage blob download --account-name <old-storage> --container-name tfstate --name terraform.tfstate --file backup.tfstate --auth-mode login
   ```

2. **Run the new backend setup workflow**

3. **Import existing state** (if needed):
   ```bash
   # Upload to new backend location
   az storage blob upload --account-name <new-storage> --container-name tfstate --name main/terraform.tfstate --file backup.tfstate --auth-mode login
   ```

## Troubleshooting

### Backend Already Exists

The workflow automatically detects existing backend resources. If resources exist and you don't use `force_recreate`, the workflow will skip creation.

### Missing Secrets

If the main deployment workflow fails with backend errors:

1. Check that all `TF_BACKEND_*` secrets are configured
2. Run the backend setup workflow if needed
3. Ensure the access key secret is correctly added

### Force Recreation

To recreate backend resources (⚠️ **use with caution**):

1. Run the "Setup Terraform Backend" workflow
2. Enable the `force_recreate` option
3. This will destroy and recreate all backend resources

### Manual Backend Management

If you need to manage the backend manually:

```bash
# Navigate to backend directory
cd terraform/backend

# Initialize Terraform (uses local state for bootstrapping)
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Get outputs
terraform output
```

## Security Features

- **Resource Protection**: `prevent_destroy` lifecycle rules prevent accidental deletion
- **Secure Storage**: HTTPS-only, TLS 1.2 minimum, private containers
- **State Versioning**: Blob versioning enabled for state history
- **Separate State**: Backend uses local state to avoid circular dependency

## State File Organization

| Path | Description |
|------|-------------|
| `main/terraform.tfstate` | Main n8n infrastructure |
| `static-web-app/terraform.tfstate` | Static web application |
| Local state | Backend infrastructure (bootstrapping) |

## Best Practices

1. **Always backup state** before major changes
2. **Use separate resource groups** for backend vs application resources
3. **Monitor access keys** and rotate them periodically
4. **Enable resource locks** on critical backend resources
5. **Use consistent naming** across environments

## Support

For issues with the backend setup:

1. Check workflow logs in GitHub Actions
2. Verify Azure service principal permissions
3. Ensure all required secrets are configured
4. Test Azure CLI authentication locally if needed