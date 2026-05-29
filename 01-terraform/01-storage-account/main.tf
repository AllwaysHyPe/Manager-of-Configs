# see https://registry.terraform.io/providers/hashicorp/random/3.8.1/docs/resources/pet
resource "random_pet" "main" {
  length = 1
}

# see https://registry.terraform.io/providers/hashicorp/random/3.8.1/docs/resources/string
resource "random_string" "main" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

locals {
  resource_suffix = "${random_pet.main.id}${random_string.main.result}"
}

# see https://registry.terraform.io/modules/Azure/naming/azurerm/latest
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"

  prefix = ["mgrcnfgs"]
  suffix = [local.resource_suffix]
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/resource_group
resource "azurerm_resource_group" "main" {
  location = var.azure_region
  name     = "${var.prefix}-${local.resource_suffix}"

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}

# see https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest
module "storage" {
  # The AVM handles encryption, network rules, blob properties, and other
  # settings 
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "4.67.0"

  name                      = module.naming.storage_account.name_unique
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  shared_access_key_enabled = true

  # The AVM defaults to ZRS. ZRS is not available in all regions including
  # westus, so LRS is set explicitly here.
  account_replication_type = "LRS"

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}
