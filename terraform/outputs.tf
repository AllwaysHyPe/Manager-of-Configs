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

# Uncomment after Exercise 1
output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = azurerm_storage_account.main.name
}

# # Uncomment after Exercise 2
output "vm_admin_password" {
  description = "Admin password for the Windows VM"
  sensitive   = true
  value       = random_password.vm_admin.result
}

output "vm_public_ip" {
  description = "Public IP address of the Windows VM"
  value       = azurerm_public_ip.main.ip_address
}