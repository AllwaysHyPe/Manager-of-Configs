> **Bonus / Deep-Dive Content:** This is supplementary material. Core path attendees can return here after the workshop.

---
# Chapter 6: Reference - HCP Terraform Authentication and Manual Setup
**Duration:** Reference only (not part of the normal workshop flow)  
**Objective:** Preserve manual setup details for teams that need to wire HCP Terraform outside the preconfigured lab environment

---

## When to Use This Chapter

Use this chapter only if:
- you are reproducing the workshop in a new repository that is not preconfigured
- you need to manually authenticate to HCP Terraform
- you need to migrate local state to HCP Terraform

Do not use this chapter for the normal learner flow in this workshop.

---

## Core Workshop Reminder

In the standard lab path:
- the repository root is the lab environment
- HCP Terraform is already preconfigured
- deployments are triggered by push to `main` in the learner copy

---

## Manual Setup Steps (Reference)

### 1. Create HCP account and org

1. Go to https://app.terraform.io
2. Create/sign in to your account
3. Create organization (for example `my-org`)

### 2. Create API token

In HCP Terraform:
- Account Settings -> Tokens -> Create API token

Set token locally:

```bash
export TF_TOKEN_app_terraform_io="<your-token>"
```

PowerShell:

```powershell
$env:TF_TOKEN_app_terraform_io = "<your-token>"
```

### 3. Create workspace

Create a workspace (for example `storage-workshop`).

### 4. Add `terraform { cloud {} }` block

Add this to your Terraform config:

```hcl
terraform {
  cloud {
    organization = "my-org"

    workspaces {
      name = "storage-workshop"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.66"
    }
  }
}
```

### 5. Reinitialize and migrate state

```bash
terraform init
```

If prompted to copy existing state, answer `yes`.

### 6. Verify run behavior

```bash
terraform plan
```

Then confirm state and run history appear in HCP workspace UI.

---

## Optional Helper Scripts

Reference scripts in [scripts](./scripts):
- `configure-hcp-terraform.sh`
- `configure-hcp-terraform.ps1`

These are helpers for non-preconfigured environments.

---

## Sentinel and Governance (Reference)

Sentinel policies can be used to enforce rules such as:
- required tags
- VM size limits
- no public storage in restricted environments

This workshop does not require participants to author Sentinel policies in the core path.

---

## Return to Core Flow

After reviewing this reference, continue with:

- [bonus-copilot-and-mcp.md](./bonus-copilot-and-mcp.md)

---

**Related:** [Chapter 4: Deploy with AVM](../04_Deploy_with_AVM.md)

