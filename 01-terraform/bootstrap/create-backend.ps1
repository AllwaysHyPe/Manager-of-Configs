#!/usr/bin/env pwsh

# The backend is bootstrapped outside the main Terraform configuration on
# purpose. Terraform needs the storage account to exist before it can init,
# which means you cannot use Terraform to create the thing Terraform depends on.
# This script is the one manual step in an otherwise fully automated pipeline.

$ErrorActionPreference = "Stop"

$resourceGroupName   = if ($env:RESOURCE_GROUP_NAME)   { $env:RESOURCE_GROUP_NAME }   else { "mgr-of-configs" }
$location            = if ($env:LOCATION)               { $env:LOCATION }               else { "westus" }
$containerName       = if ($env:CONTAINER_NAME)         { $env:CONTAINER_NAME }         else { "tfstate" }
$storageAccountName  = if ($env:STORAGE_ACCOUNT_NAME)   { $env:STORAGE_ACCOUNT_NAME }   else { "mgrofconfigs" }

# Ensure storage account name is lowercase and within the 24 character limit.
$storageAccountName = $storageAccountName.ToLower()
$storageAccountName = $storageAccountName.Substring(0, [Math]::Min(24, $storageAccountName.Length))

Write-Host "Creating backend infrastructure..." -ForegroundColor Cyan

Write-Host "Creating resource group: $resourceGroupName" -ForegroundColor Yellow
az group create `
  --name $resourceGroupName `
  --location $location `
  --output none

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create resource group"
    exit 1
}

Write-Host "Creating storage account: $storageAccountName" -ForegroundColor Yellow
az storage account create `
  --name $storageAccountName `
  --resource-group $resourceGroupName `
  --location $location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-blob-public-access false `
  --min-tls-version TLS1_2 `
  --output none

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create storage account"
    exit 1
}

Write-Host "Creating blob container: $containerName" -ForegroundColor Yellow
az storage container create `
  --name $containerName `
  --account-name $storageAccountName `
  --auth-mode login `
  --output none

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create container"
    exit 1
}

# The output is copy/paste friendly. The next step is to put these values
# into backend.azurerm.tfbackend and run terraform init.
Write-Host ""
Write-Host "Backend created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Copy this into backend.azurerm.tfbackend:" -ForegroundColor Cyan
Write-Host ""
Write-Host "resource_group_name  = `"$resourceGroupName`""
Write-Host "storage_account_name = `"$storageAccountName`""
Write-Host "container_name       = `"$containerName`""
Write-Host 'key                  = "mgr-of-configs/00-base.tfstate"'
Write-Host "use_azuread_auth     = true"
Write-Host ""
Write-Host "Update the key for each stage:" -ForegroundColor Yellow
Write-Host "  00-base:              mgr-of-configs/00-base.tfstate"
Write-Host "  01-storage-account:   mgr-of-configs/01-storage-account.tfstate"
Write-Host "  02-avm-storage:       mgr-of-configs/02-avm-storage.tfstate"
Write-Host "  03-windows-vm:        mgr-of-configs/03-windows-vm.tfstate"
Write-Host ""