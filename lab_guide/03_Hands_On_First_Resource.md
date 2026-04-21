# Chapter 3: Hands-On - Deploy Your First Resource
**Duration:** 45-50 minutes  
**Objective:** Make your first Terraform change and deploy it through the learner-copy git push workflow

---

## Learning Outcomes

By the end of this chapter, participants will be able to:
- [ ] Update Terraform in the repository root
- [ ] Run local checks (`fmt`, `validate`, `plan`)
- [ ] Commit and push from their learner copy
- [ ] Confirm deployment by reviewing the HCP Terraform run
- [ ] Troubleshoot common first-run issues

---

## Timing Breakdown
- Setup and orientation: 4 min
- Edit Terraform files: 8 min
- Local checks: 5 min
- Commit and push: 5 min
- Verify run and outputs: 5 min
- Q&A: 3 min
- **Exercise 1 subtotal: ~25-30 min**
- Exercise 2 intro and uncomment: 5 min
- Local checks (plan with 9 resources): 3 min
- Commit and push: 2 min
- Wait for HCP run + verify IIS page: 8 min
- **Exercise 2 subtotal: ~18 min**

## Important Workflow Note

The lab environment is the repository root. HCP Terraform is already preconfigured. In this workshop chapter, deployment happens from push, not by local `terraform apply`.

> **🔐 How HCP Terraform authenticates to Azure**
> 
> This workshop uses a pre-configured HCP Terraform workspace with a service principal credential stored as a workspace environment variable (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`). When you push code, HCP Terraform runs `terraform plan/apply` using these credentials — you never need to configure Azure auth locally.
> 
> For production use, HashiCorp recommends OIDC (dynamic credentials) over static service principal secrets. See: [HCP Terraform Dynamic Provider Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)

---

## Part 1: Prepare Your Learner Copy on Main

From the repository root:

```bash
git checkout main
git pull
```

---

## Part 2: Update Terraform for the First Resource

This exercise uses **Exercise 1: Storage Account** — the commented block already in `main.tf`.

Checklist:
- [ ] Uncomment the `azurerm_storage_account` block in `main.tf`
- [ ] Uncomment the `storage_account_name` output in `outputs.tf`
- [ ] Keep names and variables aligned with workshop naming guidance

Tip:
- The naming module already generates a unique storage account name — no manual suffix needed.

---

## Part 3: Run Local Safety Checks

Run these from repository root:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

What to look for:
- `init` initializes the HCP Terraform backend — required once per Codespace session
- `fmt` makes style consistent
- `validate` confirms configuration is structurally correct
- `plan` confirms only expected resources are changing

If `plan` shows unexpected deletes, stop and review before pushing.

---

## Part 4: Deploy by Commit and Push

```bash
git add main.tf outputs.tf
git commit -m "lab: chapter 3 first resource"
git push origin main
```

Workshop rule:
- deployment is triggered by push to `main` in your learner copy.

---

## Part 5: Verify the HCP Terraform Run

After push:
- open the run in HCP Terraform
- confirm run status reaches `Applied` (or expected plan-only status)
- review outputs for resource identifiers
- confirm resources in Azure portal under the expected workshop deployment context

---

## Common Issues and Fixes

### Name already taken
- Update the resource name to a unique value and push again.

### Validation error
- Read the exact field and fix it locally, rerun `terraform validate`, then recommit.

### Plan includes unexpected changes
- Revert unintended edits, rerun plan, then push.

### HCP run failed after push
- Open run logs in HCP first.
- Fix code in learner copy and push a follow-up commit.

---

## Quick Verification Checklist

Before moving on:

**Exercise 1: Storage Account**
- [ ] Ran `terraform fmt`, `terraform validate`, and `terraform plan`
- [ ] Committed and pushed from learner copy
- [ ] Saw HCP run trigger from push
- [ ] Confirmed expected resource outcome

**Exercise 2: Windows VM with IIS**
- [ ] Uncommented all 9 Exercise 2 resource blocks in `main.tf`
- [ ] Plan showed ~9 new resources (VNet, subnet, public IP, NSG, NIC, NSG association, password, VM, extension)
- [ ] Confirmed HCP run completed (note: takes longer than Exercise 1)
- [ ] Browsed to the public IP and saw the IIS welcome page

---

## Exercise 2: Windows VM with IIS

Exercise 2 builds on the same edit-validate-push pattern but deploys a more complex resource: a Windows Server 2022 VM with full networking and IIS pre-installed via a CustomScriptExtension. This exercise demonstrates how Terraform automatically manages resource dependencies — the NIC depends on the subnet and public IP, the VM depends on the NIC, and the extension depends on the VM — without any manual ordering on your part.

### What Gets Uncommented

Uncomment these 9 resource blocks in `main.tf`:

| Resource | Purpose |
|---|---|
| `azurerm_virtual_network` | VNet for the VM |
| `azurerm_subnet` | Subnet inside the VNet |
| `azurerm_public_ip` | Public IP for inbound access |
| `azurerm_network_security_group` | NSG allowing inbound HTTP on port 80 |

> ⚠️ **Workshop-only configuration:** This NSG allows inbound HTTP (port 80) from any source (`*`). This is intentional for the workshop so you can verify IIS is running. In production, restrict `source_address_prefix` to known IP ranges and enable HTTPS.

> ⚠️ **Azure VM SKU Selection for Windows:** Always use D-series v4 SKUs for Windows VMs for optimal performance and cost efficiency. The workshop uses `Standard_D2_v4` (Intel, v4 generation). Reference: [Azure VM Sizes — D-series v4](https://learn.microsoft.com/en-us/azure/virtual-machines/dv4-dsv4-series)
| `azurerm_network_interface` | NIC connecting VM to subnet and public IP |
| `azurerm_network_interface_security_group_association` | Links the NIC to the NSG |
| `random_password.vm_admin` | Generates a secure admin password |
| `azurerm_windows_virtual_machine` | Windows Server 2022 Datacenter VM (Standard_D2_v4 — Intel SKU) |
| `azurerm_virtual_machine_extension.iis` | Installs IIS via CustomScriptExtension |

### Steps

1. **Uncomment all 9 blocks** in `main.tf`.

2. **Check `outputs.tf`** for any VM-related outputs (e.g., public IP) and uncomment them if present.

3. **Run local checks:**

   ```bash
   terraform fmt
   terraform validate
   terraform plan
   ```

   The plan should show approximately 9 new resources. If unexpected deletes appear, stop and review before pushing.

4. **Commit and push:**

   ```bash
   git add main.tf outputs.tf
   git commit -m "lab: chapter 3 exercise 2 - windows vm with iis"
   git push origin main
   ```

5. **Watch the HCP run** — VM provisioning and the IIS extension install will take longer than the storage account. Expect 5–10 minutes for the run to complete.

### Verification

After the HCP run reaches `Applied`:

- Find the public IP in the run outputs, the HCP UI, or the Azure portal.
- Open a browser and navigate to `http://{public-ip}`.
- You should see the **"Hello from workshop-{suffix}!"** page served by IIS.

> **Note:** If the page doesn't load immediately, wait 1–2 minutes for IIS to finish initializing and try again.

---

## Transition to Chapter 4

"You now have the full deployment loop in place: edit, validate, push, review run. Next we keep the same deployment loop but replace handwritten resource blocks with Azure Verified Modules."

---

**Next:** [Chapter 4: Deploy with Azure Verified Modules](./04_Deploy_with_AVM.md)
