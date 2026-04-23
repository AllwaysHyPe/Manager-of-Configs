# 01-storage-account

Adds a storage account to the base resource group.

## What this deploys

- Resource group named `mgrcnfgs-{random}`
- Storage account named `mgrcfg{random}`

## Setup

```bash
cp backend.azurerm.tfbackend.example backend.azurerm.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

## Commands

```bash
terraform init "-backend-config=backend.azurerm.tfbackend"
terraform fmt
terraform validate
terraform plan "-out=tfplan"
terraform apply tfplan
```

## Tear down

```bash
terraform destroy -auto-approve
```