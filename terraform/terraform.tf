terraform {
  required_version = ">= 1.14.0, < 2.0.0"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.67.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.8.0, < 4.0.0"
    }
  }
}