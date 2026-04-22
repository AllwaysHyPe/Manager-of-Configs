#!/usr/bin/env bash

set -euo pipefail

# The backend is bootstrapped outside the main Terraform configuration on
# purpose. Terraform needs the storage account to exist before it can init,
# which means you cannot use Terraform to create the thing Terraform depends on.
# This script is the one manual step in an otherwise fully automated pipeline.

resource_group_name="${RESOURCE_GROUP_NAME:-mgr-of-configs}"
location="${LOCATION:-westus}"
container_name="${CONTAINER_NAME:-tfstate}"
storage_account_name="${STORAGE_ACCOUNT_NAME:-mgrofconfigs}"

# Ensure storage account name is lowercase and within the 24 character limit.
storage_account_name="${storage_account_name,,}"
storage_account_name="${storage_account_name:0:24}"

echo "Creating backend infrastructure..."

az group create \
  --name "$resource_group_name" \
  --location "$location" \
  --output none

az storage account create \
  --name "$storage_account_name" \
  --resource-group "$resource_group_name" \
  --location "$location" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --output none

az storage container create \
  --name "$container_name" \
  --account-name "$storage_account_name" \
  --auth-mode login \
  --output none

# The output is copy/paste friendly. The next step is to put these values
# into backend.azurerm.tfbackend and run terraform init.
cat <<EOF

Backend created successfully.

Copy this into backend.azurerm.tfbackend:

resource_group_name  = "$resource_group_name"
storage_account_name = "$storage_account_name"
container_name       = "$container_name"
key                  = "mgr-of-configs/00-base.tfstate"
use_azuread_auth     = true

Update the key for each stage:
  00-base:             mgr-of-configs/00-base.tfstate
  01-storage-account:  mgr-of-configs/01-storage-account.tfstate
  02-avm-storage:      mgr-of-configs/02-avm-storage.tfstate
  03-windows-vm:       mgr-of-configs/03-windows-vm.tfstate
EOF