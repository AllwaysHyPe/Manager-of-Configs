variable "azure_region" {
  default     = "westus"
  description = "Azure region for all resources"
  type        = string
}

variable "prefix" {
  default     = "mgr-of-configs"
  description = "Prefix applied to all resource names"
  type        = string
}