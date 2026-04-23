# Stage 01 adds a storage account to the base resource group.


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
  # Same suffix pattern as every other stage so resource names stay
  # consistent and recognizable as the demo progresses.
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

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/storage_account
resource "azurerm_storage_account" "main" {
  # Storage account names cannot contain hyphens and have a 24 character limit.
  # We build the name directly using a short prefix and the random string rather
  # than using the naming module, which would produce an invalid name with the
  # mgrcnfgs prefix. mgrcfg (6) + random string (4) = 10 characters total.

  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.main.location
  name                     = "mgrcfg${random_string.main.result}"
  resource_group_name      = azurerm_resource_group.main.name

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}