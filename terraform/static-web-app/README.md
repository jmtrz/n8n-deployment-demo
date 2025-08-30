# Azure Static Web App Terraform Configuration

This Terraform configuration creates an Azure Static Web App for hosting the Angular deployment dashboard application.

## Prerequisites

1. **Azure CLI** installed and logged in
2. **Terraform** >= 1.0 installed
3. **Azure Service Principal** with appropriate permissions
4. **GitHub repository** with the Angular application

## Resources Created

- **Resource Group**: Container for all resources
- **Static Web App**: Hosts the Angular application
- **Application Insights**: Application monitoring and analytics
- **Log Analytics Workspace**: Centralized logging
- **Storage Account** (optional): Additional asset storage
- **CDN Profile & Endpoint** (optional): Global content delivery

## Quick Start

### 1. Backend Setup

First, ensure you have the Terraform backend storage created:

```bash
# Run this from the root terraform directory
cd ../
./scripts/create-backend.sh
```

### 2. Configure Variables

Edit `terraform.tfvars` to match your requirements:

```hcl
project_name = "your-project-name"
environment  = "prod"
location     = "East US"
sku_tier     = "Free"  # or "Standard" for production
```

### 3. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 4. GitHub Secrets Setup

After applying Terraform, set up these GitHub repository secrets:

```bash
# Get the deployment token
terraform output -raw deployment_token
```

Add these secrets to your GitHub repository:

- `AZURE_CREDENTIALS`: Service principal credentials JSON
- `AZURE_STATIC_WEB_APPS_API_TOKEN`: Deployment token from Terraform output

## Configuration Options

### SKU Tiers

- **Free**: 
  - 100 GB bandwidth/month
  - 0.5 GB storage
  - Custom domains not supported
  
- **Standard**: 
  - 100 GB bandwidth/month (then pay-as-you-go)
  - 0.5 GB storage
  - Custom domains supported
  - Staging environments

### Optional Features

Enable additional features by setting these variables:

```hcl
create_storage = true   # Additional storage account
create_cdn     = true   # CDN for global performance
custom_domain  = "dashboard.yourdomain.com"
```

## GitHub Actions Integration

The configuration works with the GitHub Actions workflow located at:
`.github/workflows/deploy-static-web-app.yml`

The workflow will:
1. Run `terraform plan` on pull requests
2. Run `terraform apply` on main branch pushes
3. Build and deploy the Angular application
4. Clean up resources on closed PRs (optional)

## Monitoring and Logging

### Application Insights

Monitor your application performance:
- Navigate to the Azure portal
- Find your Application Insights resource
- View metrics, logs, and application map

### Log Analytics

Query application logs:
```kql
traces
| where timestamp > ago(1d)
| order by timestamp desc
```

## Security Considerations

1. **Service Principal**: Use least-privilege permissions
2. **Secrets**: Store sensitive values in GitHub Secrets
3. **Network**: Consider IP restrictions for production
4. **HTTPS**: Always enforced on Static Web Apps

## Cost Optimization

- Use **Free** tier for development/testing
- Monitor bandwidth usage
- Consider CDN only for global applications
- Set up budget alerts in Azure

## Troubleshooting

### Common Issues

1. **Backend state lock**: 
   ```bash
   terraform force-unlock LOCK_ID
   ```

2. **Permission errors**: Verify service principal has:
   - Contributor role on subscription
   - User Access Administrator (if using custom domains)

3. **Deployment token not found**: 
   ```bash
   terraform refresh
   terraform output deployment_token
   ```

### Useful Commands

```bash
# View all outputs
terraform output

# Show current state
terraform show

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

⚠️ **Warning**: This will permanently delete all resources and data.

## Support

For issues:
1. Check Terraform logs
2. Verify Azure permissions
3. Review GitHub Actions workflow logs
4. Check Azure portal for resource status