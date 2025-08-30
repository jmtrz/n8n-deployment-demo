#!/bin/bash

# Azure Service Principal Setup for GitHub Actions
# Run this script to create the required service principal and get the credentials

set -e

echo "🚀 Setting up Azure Service Principal for GitHub Actions..."

# Check if Azure CLI is installed and logged in
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure first:"
    echo "   az login"
    exit 1
fi

# Get current subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)

echo "📋 Current Azure Subscription:"
echo "   Name: $SUBSCRIPTION_NAME"
echo "   ID: $SUBSCRIPTION_ID"

# Prompt for service principal name
read -p "🏷️  Enter service principal name (default: sp-github-actions-n8n): " SP_NAME
SP_NAME=${SP_NAME:-sp-github-actions-n8n}

echo "🔧 Creating service principal: $SP_NAME"

# Create service principal with contributor role
SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth)

echo "✅ Service Principal created successfully!"
echo ""
echo "📝 GitHub Secret Configuration:"
echo "=================================================="
echo "Secret Name: AZURE_CREDENTIALS"
echo "Secret Value (copy this entire JSON):"
echo "$SP_OUTPUT"
echo "=================================================="
echo ""
echo "🔐 Additional secrets needed:"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo ""
echo "📋 Next Steps:"
echo "1. Go to your GitHub repository: https://github.com/jmtrz/n8n-deployment-demo"
echo "2. Navigate to Settings → Secrets and variables → Actions"
echo "3. Add the following repository secrets:"
echo "   - AZURE_CREDENTIALS (paste the JSON above)"
echo "   - AZURE_SUBSCRIPTION_ID (paste: $SUBSCRIPTION_ID)"
echo ""
echo "🎯 After adding secrets, re-run the GitHub Actions workflow"