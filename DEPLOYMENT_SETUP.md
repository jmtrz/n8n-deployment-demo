# Deployment Setup Guide

This guide walks you through setting up the complete CI/CD pipeline for deploying the Angular deployment dashboard to Azure Static Web Apps.

## Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **GitHub Repository** for the code
3. **Azure CLI** installed locally
4. **Terraform** >= 1.0 installed locally

## Step 1: Azure Service Principal Setup

Create a service principal for GitHub Actions:

```bash
# Login to Azure
az login

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-n8n-dashboard" \
  --role contributor \
  --scopes /subscriptions/your-subscription-id \
  --sdk-auth
```

Copy the JSON output - you'll need it for GitHub secrets.

## Step 2: Terraform Backend Setup

Run the backend setup script:

```bash
# From the project root
cd terraform
chmod +x ../scripts/create-backend.sh
../scripts/create-backend.sh
```

This creates:
- Resource group for Terraform state
- Storage account for state files
- Storage container

## Step 3: GitHub Repository Secrets

In your GitHub repository, go to Settings > Secrets and Variables > Actions, and add:

### Required Secrets

1. **AZURE_CREDENTIALS**
   ```json
   {
     "clientId": "your-client-id",
     "clientSecret": "your-client-secret",
     "subscriptionId": "your-subscription-id",
     "tenantId": "your-tenant-id"
   }
   ```
   (Use the output from Step 1)

2. **AZURE_STATIC_WEB_APPS_API_TOKEN**
   - Initially leave empty
   - Will be populated after first Terraform run

### Optional Secrets

3. **GITHUB_TOKEN** (usually auto-provided)
   - Used for pull request comments and status updates

## Step 4: Configure Terraform Variables

Edit `terraform/static-web-app/terraform.tfvars`:

```hcl
# Basic Configuration
project_name = "your-project-name"
environment  = "prod"
location     = "East US"

# For production, consider:
sku_tier = "Standard"
sku_size = "Standard"
create_cdn = true

# Monitoring
retention_days = 90

# Tags
tags = {
  Environment = "production"
  Project     = "your-project"
  Owner       = "your-team"
  ManagedBy   = "terraform"
}
```

## Step 5: Initial Terraform Deployment

Run Terraform manually for the first deployment:

```bash
cd terraform/static-web-app

# Initialize
terraform init

# Plan and review
terraform plan -var-file="terraform.tfvars"

# Apply
terraform apply -var-file="terraform.tfvars"

# Get the deployment token
terraform output -raw deployment_token
```

## Step 6: Update GitHub Secret

Take the deployment token from Step 5 and update the GitHub secret:
- Go to repository Settings > Secrets and Variables > Actions
- Update `AZURE_STATIC_WEB_APPS_API_TOKEN` with the token

## Step 7: Configure Angular Application

Update the Angular application for production:

1. **Environment Configuration** (`src/n8n-deployment-monitoring/src/environments/`):
   ```typescript
   // environment.prod.ts
   export const environment = {
     production: true,
     apiUrl: 'https://api.github.com',
     appInsightsInstrumentationKey: 'your-app-insights-key'
   };
   ```

2. **Build Configuration** (`angular.json`):
   ```json
   "build": {
     "configurations": {
       "production": {
         "budgets": [
           {
             "type": "initial",
             "maximumWarning": "500kb",
             "maximumError": "1mb"
           }
         ],
         "outputHashing": "all",
         "optimization": true,
         "sourceMap": false,
         "namedChunks": false,
         "extractLicenses": true,
         "vendorChunk": false,
         "buildOptimizer": true
       }
     }
   }
   ```

## Step 8: Workflow Triggers

The GitHub Actions workflow triggers on:

- **Push to main**: Full deployment
- **Pull Requests**: Preview deployment
- **Manual trigger**: Via workflow_dispatch

## Step 9: Monitoring Setup

### Application Insights Integration

Add to your Angular application:

```bash
npm install @microsoft/applicationinsights-web
```

```typescript
// app.module.ts or main.ts
import { ApplicationInsights } from '@microsoft/applicationinsights-web';

const appInsights = new ApplicationInsights({
  config: {
    instrumentationKey: 'your-instrumentation-key'
  }
});

appInsights.loadAppInsights();
appInsights.trackPageView();
```

### Log Analytics Queries

Useful KQL queries for monitoring:

```kql
// Application performance
requests
| where timestamp > ago(24h)
| summarize count() by bin(timestamp, 1h), resultCode
| render timechart

// Error tracking
exceptions
| where timestamp > ago(24h)
| summarize count() by type, outerMessage
| order by count_ desc

// User sessions
pageViews
| where timestamp > ago(24h)
| summarize users = dcount(user_Id) by bin(timestamp, 1h)
| render timechart
```

## Step 10: Custom Domain (Optional)

For production with custom domain:

1. **Update Terraform variables**:
   ```hcl
   sku_tier = "Standard"
   custom_domain = "dashboard.yourdomain.com"
   ```

2. **DNS Configuration**:
   ```
   CNAME dashboard your-static-web-app.azurestaticapps.net
   ```

3. **Apply changes**:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

## Workflow Behavior

### Main Branch Deployment

1. Terraform provisions/updates infrastructure
2. Angular app builds with production configuration
3. App deploys to Static Web App
4. Deployment status updates in GitHub

### Pull Request Flow

1. Terraform plans changes (no apply)
2. Angular app builds
3. Preview deployment created
4. PR comments show preview URL
5. Preview cleaned up when PR closes

### Branch Protection

Consider enabling branch protection rules:
- Require PR reviews
- Require status checks to pass
- Require branches to be up to date
- Restrict pushes to main branch

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify Azure credentials in GitHub secrets
   - Check service principal permissions

2. **Terraform State Issues**
   - Ensure backend storage exists
   - Check for state lock conflicts

3. **Build Failures**
   - Verify Node.js version compatibility
   - Check package-lock.json is committed
   - Review Angular build configuration

4. **Deployment Token Issues**
   - Regenerate token in Azure portal
   - Update GitHub secret
   - Re-run workflow

### Useful Commands

```bash
# Check Azure login
az account show

# List Static Web Apps
az staticwebapp list --output table

# Get deployment token
az staticwebapp secrets list --name your-app-name --resource-group your-rg

# Force unlock Terraform state
terraform force-unlock LOCK_ID

# Debug GitHub Actions
# - Enable debug logging in repository settings
# - Review workflow logs in Actions tab
```

## Security Best Practices

1. **Secrets Management**
   - Never commit secrets to code
   - Rotate service principal credentials regularly
   - Use least-privilege permissions

2. **Network Security**
   - Consider IP restrictions for admin endpoints
   - Use HTTPS everywhere (enforced by Static Web Apps)
   - Implement proper CORS policies

3. **Monitoring**
   - Set up alerts for deployment failures
   - Monitor application performance
   - Track security events

## Cost Management

- **Free Tier**: Suitable for development/testing
- **Standard Tier**: ~$9/month for production
- **Additional Costs**: 
  - Bandwidth overages
  - Application Insights data retention
  - Log Analytics data ingestion

Set up Azure Cost Management alerts to monitor spending.

## Next Steps

After successful deployment:

1. Configure monitoring dashboards
2. Set up alerting rules
3. Implement automated testing
4. Consider staging environment
5. Plan backup and disaster recovery

## Support

For help:
- Check GitHub Actions workflow logs
- Review Terraform plan output
- Monitor Azure portal for resource health
- Use Azure Support for platform issues