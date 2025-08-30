# Azure Service Principal Setup

## Quick Setup Commands

Run these commands in your terminal (make sure you're logged into Azure CLI):

```bash
# 1. Login to Azure
az login

# 2. Get your subscription ID
az account show --query id --output tsv

# 3. Create service principal (replace YOUR_SUBSCRIPTION_ID)
az ad sp create-for-rbac \
  --name "sp-github-actions-n8n" \
  --role contributor \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth
```

## GitHub Secrets to Add

Go to: https://github.com/jmtrz/n8n-deployment-demo/settings/secrets/actions

Add these secrets:

### 1. AZURE_CREDENTIALS
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret", 
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

### 2. AZURE_SUBSCRIPTION_ID
```
your-subscription-id
```

## Alternative: Using Azure Portal

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** → **App registrations**
3. Click **New registration**
4. Name: `sp-github-actions-n8n`
5. Click **Register**
6. Copy **Application (client) ID** and **Directory (tenant) ID**
7. Go to **Certificates & secrets** → **New client secret**
8. Copy the **secret value**
9. Go to **Subscriptions** → your subscription → **Access control (IAM)**
10. Click **Add** → **Add role assignment**
11. Select **Contributor** role
12. Assign to your service principal

## Verify Setup

After adding secrets, check the GitHub Actions logs to ensure the Azure login step passes.

## Troubleshooting

- **Login failed**: Check that all 4 values (clientId, clientSecret, subscriptionId, tenantId) are correct
- **Permission denied**: Ensure service principal has Contributor role on the subscription
- **Invalid tenant**: Verify tenantId matches your Azure AD tenant