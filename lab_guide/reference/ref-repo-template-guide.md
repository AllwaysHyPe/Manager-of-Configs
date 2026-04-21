# Reference: Repo Template Guide
> This is supplementary material. Core path attendees can return here after the workshop.

---

# Repo Template Guide

This guide describes the standalone repository template attendees can clone after the workshop to start shipping Azure infrastructure with Terraform, GitHub Copilot, Azure Verified Modules, and HCP Terraform.

This repository is the concrete starter artifact that matches this guide. Treat this repo as the cloneable baseline attendees can inspect during the workshop and lift into their own repos afterward.

## Purpose

The template exists to give teams a practical starting point on Monday morning.

It should help a team:

- start from a working repo instead of a blank directory
- use a repeatable Azure + Terraform workflow
- standardize how AI tools are used for Infrastructure as Code
- adopt remote state and basic governance early

## Intended Audience

This repo is designed for:

- platform teams
- cloud engineers
- DevOps engineers
- Windows-focused Azure teams that want a low-friction Terraform workflow
- teams that are new to Terraform but want an opinionated starting point

## Recommended Repository Structure

```text
powershell-summit-terraform-workshop/
├─ .devcontainer/
│  ├─ devcontainer.json
│  └─ postCreate.ps1
├─ .github/
│  ├─ copilot-instructions.md
│  ├─ agents/
│  │  └─ terraform-azure.agent.md
│  └─ skills/
│     ├─ avm-deploy/
│     │  └─ SKILL.md
│     └─ hcp-terraform-runbook/
│        └─ SKILL.md
├─ main.tf
├─ outputs.tf
├─ providers.tf
├─ terraform.tf
├─ variables.tf
├─ .gitignore
├─ .terraform-version
└─ README.md
```

## What Should Be Preconfigured

The repo should open cleanly in GitHub Codespaces.

### Dev Container Expectations

The dev container should preinstall:

- Terraform CLI
- Azure CLI
- Git
- GitHub CLI if your team uses pull-request-driven workflows
- Node.js if the Terraform MCP server is installed from npm

### VS Code Expectations

The Codespace should also include:

- GitHub Copilot
- GitHub Copilot Chat
- HashiCorp Terraform extension
- Azure-related extensions only if they support the workflow without adding noise

### Post-Create Tasks

The post-create flow should:

- verify Terraform is installed
- verify Azure CLI is installed
- surface a short "next steps" message
- optionally install or prepare the Terraform MCP server used by the team

## HCP Terraform Expectations

The template should assume the team will use HCP Terraform for remote state and runs.

### Minimum Expectations

- one HCP Terraform organization already chosen
- one workspace per environment or per service, depending on team size
- variables and secrets managed in HCP Terraform where appropriate
- local use allowed for learning, but remote state treated as the default path

### Example Pattern

```hcl
terraform {
  cloud {
    organization = "example-org"

    workspaces {
      name = "azure-platform-dev"
    }
  }
}
```

For a template repo, keep the organization and workspace names clearly marked as placeholders.

## AVM Usage Pattern

The template should prefer Azure Verified Modules before writing custom Azure resource blocks.

Recommended pattern:

1. start with an AVM for common services like storage, networking, or key vault
2. wrap it only when the team needs opinionated defaults
3. keep direct resource definitions for edge cases, not as the default authoring style

That keeps the repo faster to read, easier to maintain, and less likely to drift from Azure best practices.

## Where AI Customizations Live

### Custom Agent Files

Keep custom agents near the repo so the workflow is portable.

Recommended location:

```text
.github/agents/
```

Example:

```text
.github/agents/terraform-azure.agent.md
```

That agent should be tuned for:

- AVM-first recommendations
- resource-group-scoped deployments when applicable
- HCP Terraform awareness
- conservative changes and validation before apply

### Skill Files

Keep reusable skills in:

```text
.github/skills/
```

Recommended starter skills:

- `avm-deploy`
- `hcp-terraform-runbook`

These should encode patterns your team wants repeated consistently.

## Recommended Starter Content

The template should include:

- one working environment example under `infra/`
- one AVM-based deployment example
- one `terraform.tfvars.example`
- one short `README.md`
- one agent file and one or two simple skill files
- one devcontainer definition so the repo opens cleanly in Codespaces

## Minimal Team Adoption Path

If a team wants to start using this next week, keep the rollout simple.

### Day 1

- clone the template
- open in Codespaces
- sign in to Azure
- point the dev environment at a non-production resource group
- run `terraform init`, `terraform plan`, and `terraform apply`

For this workshop specifically, compare the guide with the files in this repository root so attendees can move from concepts to a concrete starter repo without extra translation.

### Week 1

- connect the repo to HCP Terraform
- create one workspace for `dev`
- add a pull-request validation workflow
- use the custom agent for small refactors and new module scaffolding

### Week 2 and Beyond

- add `prod` or additional environments
- introduce more AVM modules
- codify naming, tagging, and security checks as skills or CI checks
- decide where policy should live: CI, HCP Terraform, or both

## Design Principles

Keep the template opinionated in the right places.

- optimize for fast onboarding
- prefer proven modules over handwritten boilerplate
- assume teams need guardrails, not maximum flexibility on day one
- keep examples small enough to understand in one sitting
- make the AI workflow visible instead of implicit

## Success Criteria

The template is successful if a new team can:

- clone it
- open it in Codespaces
- authenticate to Azure
- deploy into a known resource group
- see how Copilot, MCP, AVMs, and HCP Terraform fit together
- extend it without rewriting the foundation

