variable "azure_region" {
  default     = "westus"
  description = "Azure region for all resources"
  type        = string
}

variable "prefix" {
  default     = "mgrcnfgs"
  description = "Prefix applied to all resource names"
  type        = string
}