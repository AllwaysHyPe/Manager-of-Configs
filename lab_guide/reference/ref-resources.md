# Reference: Workshop Resources
> This is supplementary material. Core path attendees can return here after the workshop.

---

# Workshop Resources & Reference Guide

This file is the copy-paste companion for the workshop. It is optimized for the redesigned flow: GitHub Codespaces first, Azure Verified Modules first, GitHub Copilot for authoring, Terraform MCP for validation, and HCP Terraform for shallow but practical governance.

## Companion Artifacts

- Use this repository root when you want the concrete starter repository discussed in the workshop.
- Use [ref-repo-template-guide.md](./ref-repo-template-guide.md) when you want the rationale behind the structure and rollout model.
- Use this file when you need copy-paste prompts, commands, snippets, and troubleshooting during demos.

## Table of Contents

1. [Core References](#core-references)
2. [Starter Terraform Examples](#starter-terraform-examples)
3. [HCP Terraform Example](#hcp-terraform-example)
4. [Copilot Prompt Pack](#copilot-prompt-pack)
5. [Custom Agent Example](#custom-agent-example)
6. [Simple Skill Examples](#simple-skill-examples)
7. [Useful Commands](#useful-commands)
8. [Troubleshooting](#troubleshooting)

## Core References

### Terraform and Azure

- [Terraform Registry](https://registry.terraform.io/)
- [AzureRM Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [HashiCorp Terraform CLI Docs](https://developer.hashicorp.com/terraform/cli)
- [Azure Terraform Guidance](https://learn.microsoft.com/en-us/azure/developer/terraform/)

### Azure Verified Modules

- [Azure Verified Modules](https://aka.ms/avm)
- [Azure Modules in the Terraform Registry](https://registry.terraform.io/namespaces/Azure)

### GitHub Copilot and MCP

- [GitHub Copilot Docs](https://docs.github.com/en/copilot)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Terraform MCP Server](https://github.com/hashicorp/terraform-mcp-server)

### HCP Terraform

- [HCP Terraform Docs](https://developer.hashicorp.com/terraform/cloud-docs)
- [HCP Terraform Workspaces](https://developer.hashicorp.com/terraform/cloud-docs/workspaces)

### Workshop-Specific Files

- `README.md`
- `main.tf`
- `.github/agents/terraform-azure.agent.md`
- `.github/skills/avm-deploy/SKILL.md`
- `.github/skills/hcp-terraform-runbook/SKILL.md`

## Starter Terraform Examples

### Minimal AzureRM Provider Setup

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Existing Resource Group Pattern

Use this in the workshop because attendees deploy into a pre-provisioned resource group.

```hcl
data "azurerm_resource_group" "workshop" {
  name = var.resource_group_name
}
```

### AVM-Based Storage Example

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "workshop" {
  name = var.resource_group_name
}

module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.5"

  name                = var.storage_account_name
  location            = data.azurerm_resource_group.workshop.location
  resource_group_name = data.azurerm_resource_group.workshop.name

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    workshop    = "terraform-ai"
    managedBy   = "terraform"
  }
}

output "storage_account_id" {
  value = module.storage.resource_id
}
```

```hcl
variable "resource_group_name" {
  type        = string
  description = "Workshop resource group name provided by the instructor"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique storage account name"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment label"
}
```

```hcl
resource_group_name  = "rg-terraform-workshop-firstname-lastname"
storage_account_name = "stfirstnamelast01"
environment          = "dev"
```

### Suggested File Layout for the Demo

```text
workshop/
├─ main.tf
├─ variables.tf
├─ outputs.tf
└─ terraform.tfvars
```

## HCP Terraform Example

Use this when showing the shallow HCP Terraform integration.

```hcl
terraform {
  cloud {
    organization = "example-org"

    workspaces {
      name = "terraform-workshop-dev"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
```

### HCP Terraform Environment Variable

```bash
export TF_TOKEN_app_terraform_io="<your-token>"
```

### Minimal HCP Talking Points

- remote state replaces local `terraform.tfstate`
- the team can see the same run history
- GitHub integration can trigger plans automatically
- policy exists, even if the workshop only touches it lightly

## Copilot Prompt Pack

These prompts are designed for workshop demos and beginner use.

### Generate an AVM Deployment

```text
I am deploying to Azure with Terraform.
I already have an existing resource group.
Generate minimal Terraform that uses an Azure Verified Module to create a storage account.
Use variables for the resource group name, storage account name, and environment.
Keep it simple and explain each block.
```

### Refactor Handwritten Terraform to AVM

```text
Refactor this Azure Terraform code to use an Azure Verified Module where possible.
Preserve the existing intent.
Keep the result beginner-friendly and call out any inputs I still need to provide.
```

### Prepare for HCP Terraform

```text
Add the minimum Terraform configuration needed to move this project to HCP Terraform.
Use placeholders for the organization and workspace names.
Do not change the rest of the deployment logic.
```

### Explain a Terraform Error

```text
I ran terraform validate and got this error:

<paste error here>

Explain what caused it and show the smallest fix.
```

### Generate a Safer Variable File

```text
Generate a terraform.tfvars.example file for this project.
Use safe placeholders and short comments so a beginner knows what to replace.
```

## Custom Agent Example

This is a simple repo-scoped custom agent attendees can create in VS Code during the workshop.

Suggested file:

```text
.github/agents/terraform-architect.agent.md
```

Example content:

```md
---
name: Terraform Architect
description: Helps design and refactor Azure Terraform with AVM-first guidance.
tools: [read, edit, search, execute]
---

You are a Terraform-focused Azure infrastructure assistant.

Goals:
- Prefer Azure Verified Modules when they fit the scenario.
- Assume the user may be new to Terraform.
- Prefer deployment into an existing Azure resource group when working in workshop contexts.
- When suggesting HCP Terraform, keep the explanation shallow and practical.
- Before suggesting `terraform apply`, recommend `terraform fmt` and `terraform validate`.

When authoring code:
- Keep examples minimal.
- Use variables instead of hardcoding names.
- Explain why each block exists.
```

## Simple Skill Examples

These are intentionally small so attendees can understand and create them during the workshop.

### Skill 1: AVM Storage Pattern

Suggested file:

```text
.github/skills/avm-storage-pattern/SKILL.md
```

Example content:

```md
# AVM Storage Pattern

Use this skill when creating a basic Azure storage account with Terraform.

## Rules

- Prefer the Azure Verified Module for storage accounts.
- Assume the resource group already exists unless the user explicitly says otherwise.
- Use variables for resource group name, storage account name, and environment.
- Add tags for environment and managedBy.

## Output Shape

- `main.tf` with provider, resource-group data source, and AVM module
- `variables.tf` with clear descriptions
- `terraform.tfvars.example` with safe placeholders
```

### Skill 2: Resource Group Safe Deploy

Suggested file:

```text
.github/skills/rg-safe-deploy/SKILL.md
```

Example content:

```md
# Resource Group Safe Deploy

Use this skill when working in environments where the user only has permissions at the resource-group scope.

## Rules

- Do not assume subscription-level access.
- Prefer `data "azurerm_resource_group"` over creating a new resource group.
- Keep examples scoped to resources that can be created inside the provided group.
- Call out when a requested resource requires broader permissions.
```

## Useful Commands

### Environment Checks

```bash
terraform version
git --version
```

### Terraform Workflow

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Troubleshooting

### Terraform Validate Fails

Use this sequence:

```bash
terraform fmt
terraform validate
terraform plan
```

If validation still fails, paste the error into Copilot Chat and ask for the smallest possible fix.

