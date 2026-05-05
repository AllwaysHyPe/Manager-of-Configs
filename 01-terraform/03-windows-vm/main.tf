# Stage 03 deploys the full VM stack. Terraform provisions the infrastructure
# and sets the tags that drive everything downstream. Once this apply completes
# Terraform's job is done. Ansible and Chocolatey pick up from here.

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

  # Ansible inventory generated as a Terraform output.
  ansible_inventory = {
    all = {
      hosts = {
        (azurerm_windows_virtual_machine.main.name) = {
          ansible_host     = azurerm_public_ip.main.ip_address
          ansible_user     = azurerm_windows_virtual_machine.main.admin_username
          ansible_password = "ansible_password_placeholder"
        }
      }
      vars = {
        ansible_connection                   = "winrm"
        ansible_winrm_transport              = "ntlm"
        ansible_winrm_server_cert_validation = "ignore"
        ansible_winrm_port                   = 5986
        ansible_winrm_scheme                 = "https"
      }
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "mgrcnfgs-kv-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "Set", "List", "Delete", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = random_password.vm_admin.result
  key_vault_id = azurerm_key_vault.main.id
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
    provisioner = "terraform"
    managed_by  = "ansible"
  }
}

# see https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest
module "storage" {
  # The AVM handles encryption, network rules, blob properties, and other
  # settings that the handwritten block in stage 01 left at defaults without
  # making those choices visible. Same outcome, more confidence in the result.
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  name                      = module.naming.storage_account.name_unique
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  shared_access_key_enabled = true

  # The AVM defaults to ZRS. ZRS is not available in all regions including
  # westus, so LRS is set explicitly here.
  account_replication_type = "LRS"

  tags = {
    environment = "mgr-of-configs"
    provisioner = "terraform"
    managed_by  = "ansible"
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
    provisioner = "terraform"
    managed_by  = "ansible"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/subnet
resource "azurerm_subnet" "main" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/public_ip
resource "azurerm_public_ip" "main" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  name                = module.naming.public_ip.name
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  tags = {
    environment = "mgr-of-configs"
    provisioner = "terraform"
    managed_by  = "ansible"
  }
}

# see https://registry.terraform.io/providers/hashicorp/azurerm/4.67.0/docs/resources/network_security_group
resource "azurerm_network_security_group" "main" {
  location            = azurerm_resource_group.main.location
  name                = module.naming.network_security_group.name
  resource_group_name = azurerm_resource_group.main.name

  # This rule is intentionally permissive for the demo so the IIS page is
  # reachable from any browser. In production restrict source_address_prefix
  # to known ranges and terminate HTTPS at a load balancer or App Gateway.
  tags = {
    environment = "mgr-of-configs"
    provisioner = "terraform"
    managed_by  = "ansible"
  }

}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "HTTP"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}


resource "azurerm_network_security_rule" "allow_winrm" {
  # WinRM over HTTPS on port 5986 is how Ansible communicates with Windows.
  # The GitHub Actions runner connects on this port to run playbooks.
  # In production restrict source_address_prefix to GitHub Actions IP ranges.
  name                        = "WinRM"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
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
    provisioner = "terraform"
    managed_by  = "ansible"
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
  admin_username      = "vm_admin"
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
  # Add a server with these tags and the next Ansible run picks it up
  # automatically. No hosts file to update. No manual registration.
  tags = {
    environment = "mgr-of-configs"
    provisioner = "terraform"
    managed_by  = "ansible"
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
    commandToExecute = "powershell -Command \"Install-WindowsFeature -name Web-Server -IncludeManagementTools; Set-Content -Path C:\\inetpub\\wwwroot\\index.html -Value '<html><body><h1>Manager of Configs</h1><p>Provisioned with Terraform.</p><p>Configured by Ansible.</p><p>Applications managed by Chocolatey.</p></body></html>'; $cert = New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation cert:\\LocalMachine\\My; New-Item -Path WSMan:\\localhost\\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force; Set-Item -Path WSMan:\\localhost\\Service\\Auth\\Basic -Value $true; Set-Service -Name WinRM -StartupType Automatic; Start-Service WinRM; New-NetFirewallRule -Name WinRM-HTTPS -DisplayName WinRM-HTTPS -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 5986\""
  })

  tags = {
    environment = "mgr-of-configs"
    provisioner = "terraform"
    managed_by  = "ansible"
  }
}