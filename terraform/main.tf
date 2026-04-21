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
  resource_suffix = "${random_pet.main.id}-${random_string.main.result}"
}

# see https://registry.terraform.io/modules/Azure/naming/azurerm/latest
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"

  prefix = [var.prefix]
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
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    environment = "workshop"
    managed_by  = "terraform"
  }
}

# ┌──────────────────────────────────────────────────────────────────────────────┐
# │ Exercise 1: Storage Account                                                  │
# │ Uncomment the block below to create an Azure Storage Account.                │
# └──────────────────────────────────────────────────────────────────────────────┘

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/storage_account
resource "azurerm_storage_account" "main" {
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



# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/virtual_network
resource "azurerm_virtual_network" "main" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}
#
# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/subnet
resource "azurerm_subnet" "main" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
}
#
# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/public_ip
resource "azurerm_public_ip" "main" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  name                = module.naming.public_ip.name
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/network_security_group
resource "azurerm_network_security_group" "main" {
  location            = azurerm_resource_group.main.location
  name                = module.naming.network_security_group.name
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    direction                  = "Inbound"
    name                       = "allow-http"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/network_interface
resource "azurerm_network_interface" "main" {
  location            = azurerm_resource_group.main.location
  name                = module.naming.network_interface.name
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
    subnet_id                     = azurerm_subnet.main.id
  }

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/network_interface_security_group_association
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# see https://registry.terraform.io/providers/hashicorp/random/3.8.1/docs/resources/password
resource "random_password" "vm_admin" {
  length           = 24
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "!@#$%&*()-_=+[]{}|:?,."
  special          = true
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "main" {
  admin_password      = random_password.vm_admin.result
  admin_username      = "workshopadmin"
  location            = azurerm_resource_group.main.location
  name                = module.naming.virtual_machine.name
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D2_v4"

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  # Tags are the handoff note Terraform leaves for everything downstream.
  # role        → Ansible dynamic inventory groups servers by this value
  # choco_agent → Chocolatey bootstrap targets servers where this is "true"
  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
    role        = "webserver"
    choco_agent = "true"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/virtual_machine_extension
resource "azurerm_virtual_machine_extension" "iis" {
  name                 = "install-iis"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id

  settings = jsonencode({
    commandToExecute = join("", [
      "powershell -Command \"",
      "Install-WindowsFeature -name Web-Server -IncludeManagementTools; ",
      "Set-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value '",
      "<html><head><title>Manager of Configs</title></head><body>",
      "<h1>Manager of Configs</h1>",
      "<h2>${var.prefix}-${local.resource_suffix}</h2>",
      "<p>Provisioned with Terraform.</p>",
      "<p>Configured by Ansible.</p>",
      "<p>Apps by Chocolatey.</p>",
      "</body></html>",
      "'\""
    ])
  })

  tags = {
    environment = "mgr-of-configs"
    managed_by  = "terraform"
  }
}