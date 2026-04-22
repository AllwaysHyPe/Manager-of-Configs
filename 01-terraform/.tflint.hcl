# see https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md
config {
  call_module_type = "none"
}

# see https://github.com/terraform-linters/tflint-ruleset-terraform
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# see https://github.com/terraform-linters/tflint-ruleset-azurerm
plugin "azurerm" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
  version = "0.29.0"
}