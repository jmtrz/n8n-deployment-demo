# Azure Backend Setup for Terraform State

This document explains how to set up remote state storage in Azure for better collaboration and state management.

## Benefits of Remote State

- **Consistency**: Single source of truth for infrastructure state
- **Collaboration**: Multiple team members can work on the same infrastructure
- **Security**: State stored securely in Azure with encryption
- **Backup**: Automatic backup and versioning in Azure Storage
- **Locking**: Prevents concurrent modifications

## Setup Instructions

### 1. Create Backend Resources

Run the script to create Azure Storage Account:

```bash
# Make script executable
chmod +x scripts/create-backend.sh

# Run the script (requires Azure CLI login)
./scripts/create-backend.sh
```

This creates:
- Resource Group: `terraform-state-rg`
- Storage Account: `tfstate<random>`
- Blob Container: `tfstate`

### 2. Add GitHub Secrets

Add these secrets to your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `TF_BACKEND_RESOURCE_GROUP_NAME` | Resource group for state storage | `terraform-state-rg` |
| `TF_BACKEND_STORAGE_ACCOUNT_NAME` | Storage account name | `tfstate1a2b3c4d` |
| `TF_BACKEND_CONTAINER_NAME` | Blob container name | `tfstate` |
| `TF_BACKEND_ACCESS_KEY` | Storage account access key | `abcd1234...` |

### 3. Backend Configuration

The backend is configured in `terraform/providers.tf`:

```hcl
terraform {
  backend "azurerm" {
    # Configuration provided via environment variables
  }
}
```

Configuration is passed via GitHub Actions workflow using `-backend-config` flags.

## State File Structure

- **Location**: Azure Blob Storage
- **Path**: `n8n/terraform.tfstate`
- **Encryption**: Enabled by default
- **Versioning**: Available through Azure Storage

## Workflow Integration

The GitHub Actions workflow automatically:
1. Connects to Azure backend during `terraform init`
2. Downloads existing state (if any)
3. Applies changes and updates remote state
4. Locks state during operations

## Local Development

To use the same backend locally:

```bash
# Set environment variables
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Initialize with backend
terraform init \
  -backend-config="resource_group_name=terraform-state-rg" \
  -backend-config="storage_account_name=tfstate1a2b3c4d" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=n8n/terraform.tfstate" \
  -backend-config="access_key=your-access-key"
```

## Security Considerations

- ✅ Storage account uses encryption at rest
- ✅ Access key stored as GitHub secret
- ✅ Service principal has minimum required permissions
- ✅ State file path organized by project

## Troubleshooting

### Backend Already Exists Error
If you get "backend already exists", run:
```bash
terraform init -migrate-state
```

### Access Denied
Verify:
- Service principal has Storage Blob Data Contributor role
- Correct storage account name and access key
- Resource group name is correct

### State Lock Issues
If state is locked, check for running workflows or:
```bash
terraform force-unlock <lock-id>
```

## Migration from Local State

If you have existing local state:
1. Add backend configuration
2. Run `terraform init -migrate-state`
3. Confirm migration when prompted
4. Delete local `.terraform` and `terraform.tfstate*` files