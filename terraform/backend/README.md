# Terraform Backend Setup

This module creates the Azure resources required for storing Terraform state remotely.

## What it creates

- **Resource Group**: A dedicated resource group for Terraform state storage
- **Storage Account**: Azure Storage Account with secure configuration
- **Blob Container**: Container for storing `.tfstate` files

## Usage

### Option 1: GitHub Actions (Recommended)

The backend is automatically managed through the GitHub Actions workflow `.github/workflows/setup-terraform-backend.yml`.

**To create the backend:**

1. Ensure you have the required Azure credentials in GitHub Secrets:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET` 
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`

2. Run the "Setup Terraform Backend" workflow:
   - Go to Actions tab in GitHub
   - Select "Setup Terraform Backend" 
   - Click "Run workflow"

3. The workflow will:
   - Check if backend resources already exist
   - Create resources if they don't exist (or if `force_recreate` is enabled)
   - Output the configuration values

4. **Important**: After the workflow runs, manually add the `TF_BACKEND_ACCESS_KEY` secret to your repository using the value from the workflow output.

### Option 2: Manual Creation (Legacy)

If you need to create the backend manually, you can still use the original script:

```bash
# Run the original script
./scripts/create-backend.sh
```

## Configuration

The backend module accepts these variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `resource_group_name` | Resource group name | `n8n-terraform-state-rg` |
| `location` | Azure region | `West US 2` |
| `storage_account_prefix` | Storage account prefix | `n8ntfstate` |
| `container_name` | Blob container name | `tfstate` |
| `environment` | Environment tag | `demo` |

## Outputs

The module provides these outputs for configuring your main Terraform:

- `resource_group_name`: Name of the resource group
- `storage_account_name`: Name of the storage account  
- `container_name`: Name of the blob container
- `storage_account_primary_key`: Access key (sensitive)
- `backend_config_summary`: Complete configuration object (sensitive)

## Required GitHub Secrets

After running the backend setup, ensure these secrets are configured:

```
TF_BACKEND_RESOURCE_GROUP_NAME=<output-from-workflow>
TF_BACKEND_STORAGE_ACCOUNT_NAME=<output-from-workflow>
TF_BACKEND_CONTAINER_NAME=<output-from-workflow>
TF_BACKEND_ACCESS_KEY=<output-from-workflow>
```

## Security Features

- **Prevent Destroy**: Resources have `prevent_destroy` lifecycle rule
- **HTTPS Only**: Storage account requires HTTPS traffic
- **TLS 1.2**: Minimum TLS version enforced  
- **Private Container**: Blob container is not publicly accessible
- **Versioning**: Blob versioning enabled for state history

## State File Organization

State files are organized by key:
- Main infrastructure: `main/terraform.tfstate`
- Static web app: `static-web-app/terraform.tfstate` 
- Backend itself: Uses local state (bootstrapping)

## Troubleshooting

**Backend already exists**: The workflow will detect existing resources and skip creation.

**Force recreate**: Use the `force_recreate` option in the workflow to recreate resources (⚠️ use with caution).

**Manual cleanup**: If you need to destroy the backend:

```bash
cd terraform/backend
terraform destroy
```