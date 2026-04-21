# Chapter 4: Deploy with Azure Verified Modules
**Duration:** 20-25 minutes  
**Objective:** Replace handwritten resource blocks with AVM patterns while keeping the same push-based deployment loop

---

## Learning Outcomes

By the end of this chapter, participants will:
- [ ] Understand why AVM is preferred for common Azure resources
- [ ] Update the lab configuration to use AVM inputs
- [ ] Validate locally and deploy by pushing to `main`
- [ ] Verify results in HCP Terraform and Azure

---

## Timing Breakdown
- AVM overview: 4 min
- Update Terraform files: 8 min
- Validate locally: 4 min
- Commit/push and verify run: 7 min
- Q&A: 2 min

## Why This Chapter Matters

Chapter 3 taught the workflow. Chapter 4 upgrades implementation quality. You keep the same loop (edit, validate, push) but adopt Azure Verified Modules for safer defaults and less boilerplate.

---

## Part 1: Understand the Shift

Handwritten blocks are useful for learning, but AVMs are preferred for common Azure services because they:
- encode proven defaults
- reduce repetitive boilerplate
- improve consistency across teams

---

## Part 2: Add the AVM Storage Module

The AVM exercise is not a commented block — you add it directly. Copy the blocks below into the appropriate files.

> ⚠️ **Storage Access Keys in AVM:** The Azure Verified Module defaults to `shared_access_key_enabled = false` for security. However, if your Terraform code or applications need to manage data plane resources (blob containers, queues, tables), you must set `shared_access_key_enabled = true` so Terraform can authenticate to manage nested resources. For the workshop exercises, this setting is required.

### Add to `main.tf`

Add this block after the closing `}` of the resource group resource:

```hcl
# see https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest
module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    environment = "workshop"
  }
}
```

### Add to `outputs.tf`

```hcl
output "avm_storage_account_name" {
  description = "Name of the AVM-managed storage account"
  value       = module.storage.name
}
```

Checklist:
- [ ] Paste the `module "storage"` block into `main.tf`
- [ ] Paste the output block into `outputs.tf`
- [ ] Run `terraform init` to download the AVM module before validating

---

## Part 3: Local Validation Before Push

```bash
terraform fmt
terraform validate
terraform plan
```

What to verify in plan:
- expected AVM-managed resources only
- no unintended deletes
- target resources match the preconfigured workshop deployment context

---

## Part 4: Deploy by Push From Learner Copy

```bash
git add main.tf variables.tf outputs.tf
git commit -m "lab: chapter 4 avm deployment"
git push origin main
```

Workshop rule:
- deployment is triggered by push to `main` in your learner copy.

---

## Part 5: Verify Results

In HCP Terraform:
- open the run triggered by your push
- confirm run status and resource actions
- review outputs

In Azure portal:
- confirm resources under the expected workshop deployment context
- validate expected configuration (for example HTTPS-only and naming/tag conventions)

---

## Troubleshooting

### Module source/version issue
- Rerun `terraform init`, check module source/version, recommit if needed.

### Name collision
- Update name variable, rerun plan, commit, push.

### Run failed in HCP
- Fix from run logs, then push follow-up commit.

---

## Transition

"You now have the modern hands-on path: repo-root edits, local checks, push-triggered runs, and AVM-first implementation."

Reference material for manual HCP setup/auth details (not part of normal flow):
- [reference/bonus-hcp-terraform-setup.md](./reference/bonus-hcp-terraform-setup.md)

---

**Next:** [Chapter 5: Copilot and MCP](./05_Copilot_and_MCP.md)
