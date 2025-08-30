#!/bin/bash

# Azure Backend Setup Script
# This script creates the required Azure resources for Terraform remote state

set -e

# Configuration options
USE_EXISTING_RG=${USE_EXISTING_RG:-false}  # Set to true to use existing RG

# if [ "$USE_EXISTING_RG" = true ]; then
#   RESOURCE_GROUP_NAME="n8n-resource-group"  # Same as your main infrastructure
# else
#  # Separate RG for state (recommended)
# fi

RESOURCE_GROUP_NAME="n8n-terraform-state-rg" 

STORAGE_ACCOUNT_NAME="n8ntfstate$(openssl rand -hex 3)"  # Must be globally unique
CONTAINER_NAME="tfstate"
LOCATION="West US 2"  # Same region as your main resources

echo "🚀 Creating Azure backend resources for Terraform state..."
echo "📍 Using Resource Group: $RESOURCE_GROUP_NAME"

# Create resource group (only if using separate RG)
if [ "$USE_EXISTING_RG" = false ]; then
  echo "📦 Creating resource group: $RESOURCE_GROUP_NAME"
  az group create \
    --name $RESOURCE_GROUP_NAME \
    --location "$LOCATION"
else
  echo "📦 Using existing resource group: $RESOURCE_GROUP_NAME"
fi

# Create storage account
echo "💾 Creating storage account: $STORAGE_ACCOUNT_NAME"
az storage account create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --encryption-services blob \
  --location "$LOCATION"

# Create blob container
echo "📁 Creating blob container: $CONTAINER_NAME"
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --auth-mode login

# Get storage account key
echo "🔑 Getting storage account key..."
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query '[0].value' -o tsv)

echo ""
echo "✅ Backend resources created successfully!"
echo ""
echo "📋 Backend Configuration:"
echo "========================"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: $CONTAINER_NAME"
echo "Location: $LOCATION"
echo ""
echo "🔧 Add these to your GitHub Secrets:"
echo "TF_BACKEND_RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME"
echo "TF_BACKEND_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME"
echo "TF_BACKEND_CONTAINER_NAME=$CONTAINER_NAME"
echo "TF_BACKEND_ACCESS_KEY=$ACCOUNT_KEY"
echo ""
echo "📝 Update your providers.tf with the backend configuration shown below."