output "resource_group_id" {
  description = "ID of the Azure Resource Group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "Location of the Azure Resource Group"
  value       = azurerm_resource_group.main.location
}

output "resource_group_name" {
  description = "Name of the Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_suffix" {
  description = "Random suffix used for resource naming"
  value       = local.resource_suffix
}

output "ansible_inventory" {
  description = "Ansible inventory generated from Terraform state."
  value       = yamlencode(local.ansible_inventory)
}

output "avm_storage_account_name" {
  description = "Name of the AVM-managed storage account"
  value       = module.storage.name
}

output "vm_admin_password" {
  description = "Admin password for the Windows VM."
  sensitive   = true
  value       = random_password.vm_admin.result
}

output "vm_public_ip" {
  description = "Public IP address of the Windows VM"
  value       = azurerm_public_ip.main.ip_address
}