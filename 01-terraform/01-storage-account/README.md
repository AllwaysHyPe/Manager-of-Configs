# 01-storage-account


> ⚠️ **Storage Access Keys in AVM:** The Azure Verified Module defaults to `shared_access_key_enabled = false` for security. However, if your Terraform code or applications need to manage data plane resources (blob containers, queues, tables), you must set `shared_access_key_enabled = true` so Terraform can authenticate to manage nested resources. 

## What this deploys

- Resource group named `mgrcnfgs-{random}`
- Storage account via AVM with LRS redundancy and secure defaults

## Setup

```bash
cp backend.azurerm.tfbackend.example backend.azurerm.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

## Commands

Run `terraform init` before `plan` even if you already ran it in stage 01.
The AVM module is a new source that needs to be downloaded.

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