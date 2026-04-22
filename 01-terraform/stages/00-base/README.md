# 00-base

Resource group only. The starting point for the demo.

Shows the core Terraform workflow: init, plan, apply, destroy.
Remote state is already configured so this stage is team-safe from the start.

## What this deploys

- Resource group named `mgrcnfgs-{random}`

## Setup

Run the bootstrap script once before the first init if you have not already:

```powershell
# PowerShell
../../bootstrap/create-backend.ps1
```

```bash
# Bash/WSL
../../bootstrap/create-backend.sh
```

Then copy the example files:

```bash
cp backend.azurerm.tfbackend.example backend.azurerm.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

## Commands

```bash
terraform init "-backend-config=backend.azurerm.tfbackend"
terraform plan "-out=tfplan"
terraform apply tfplan
```

## Tear down

```bash
terraform destroy -auto-approve
```