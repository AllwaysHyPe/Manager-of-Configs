# Stage 00 is the starting point: one root module, remote state, and just
# enough resources to show the plan/apply loop before anything else is
# introduced. The goal here is to demonstrate the core Terraform workflow
# and show how random naming removes an entire class of demo problems.


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
  # Combining a pet name and a random string gives a suffix that is unique,
  # human-readable, and requires zero naming decisions during the demo.
  # Every resource in every stage uses this same suffix so names stay
  # consistent as new resources are added.
  resource_suffix = "${random_pet.main.id}${random_string.main.result}"
}

# see https://registry.terraform.io/modules/Azure/naming/azurerm/latest
module "naming" {
  # The naming module generates Azure-compliant resource names automatically.
  # This means we never have to think about character limits, allowed characters,
  # or uniqueness constraints — the module handles all of that.
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"

  prefix = ["mgrcnfgs"]
  suffix = [local.resource_suffix]
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/resource_group
resource "azurerm_resource_group" "main" {
  # The resource group is the only resource in this stage. Every resource in
  # every subsequent stage references it, so implicit dependencies stay visible
  # in the plan without any explicit depends_on.
  location = var.azure_region
  name     = "${var.prefix}-${local.resource_suffix}"

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}