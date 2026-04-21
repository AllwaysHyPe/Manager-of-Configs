# PowerShell + DevOps Summit: Terraform Workshop
## Attendee Lab Manual

**Duration:** ~165 minutes core path | +30–35 minutes for stretch goal  
**Objective:** Learn Infrastructure as Code with Terraform, deploy to Azure, and harness AI tools for accelerated infrastructure development

---

## Table of Contents

1. [Prerequisites & Setup Verification](#prerequisites--setup-verification)
2. [Chapter 1: Introduction and Setup](#chapter-1-introduction-and-setup)
3. [Chapter 2: IaC & Terraform Essentials](#chapter-2-iac--terraform-essentials)
4. [Chapter 3: Hands-On - Deploy Your First Resource](#chapter-3-hands-on---deploy-your-first-resource)
5. [Chapter 4: Deploy with Azure Verified Modules](#chapter-4-deploy-with-azure-verified-modules)
6. [Chapter 5: Copilot and MCP](#chapter-5-copilot-and-mcp)
7. [Chapter 6: Skills & Knowledge Management](#chapter-6-skills--knowledge-management)
8. [Chapter 7: Copilot Customization — Instructions and Custom Agents](#chapter-7-copilot-customization--instructions-and-custom-agents) *(Stretch Goal)*
9. [Chapter 8: Wrap-Up & Next Steps](#chapter-8-wrap-up--next-steps)

---

# Prerequisites & Setup Verification

## Technical Requirements Checklist

Your workshop environment requires:

- Terraform CLI 1.14+
- Git 2.40+
- VS Code (latest stable) with GitHub Copilot and HashiCorp Terraform extensions
- GitHub account with Codespaces and Copilot access
- HCP Terraform is pre-configured for the workshop (no manual setup needed)

These versions support the commands and provider behaviors used in this lab.

## Preferred Setup: GitHub Codespaces

This is the default workshop path.

### Codespaces Should Already Include

- Terraform CLI
- Git
- VS Code extensions needed for the workshop
- GitHub Copilot
- HashiCorp Terraform extension
- Workshop sample files or starter content

### Attendee Verification Steps

After opening the Codespace, run:

```bash
terraform version
git --version
```

Then verify your learner copy is wired to the preconfigured HCP workflow and ready for push-to-main deployment.

## Local Machine Setup

Use local setup only if Codespaces is unavailable.

### Required Local Tools

- Terraform CLI 1.14+
- Git
- VS Code
- GitHub Copilot extension
- HashiCorp Terraform extension

### Local Verification

```powershell
terraform version
git --version
```

## Common Problems

### HCP Run Not Triggered After Push

Confirm you pushed to `main` in your learner copy and that the repository-to-HCP wiring is active.

### Copilot Not Available

- Confirm you are signed into GitHub in VS Code
- Confirm your account has Copilot access
- Reload the VS Code window if the extension is installed but inactive

### Codespaces Is Not Available

Use the local machine setup path above. The workshop still works, but setup will take longer.

## Ready Check

You are ready when all of these are true:

- [ ] You can open the workshop repo in GitHub Codespaces
- [ ] `terraform version` works
- [ ] You understand deployment is triggered by push to `main` in your learner copy
- [ ] GitHub Copilot is available in VS Code

If those four checks pass, the workshop can start.

---

# Chapter 1: Introduction and Setup
**Duration:** 15 minutes  
**Objective:** Access your pre-created workshop repository, open it in GitHub Codespaces, and prepare for push-based deployment

## Learning Outcomes

By the end of this chapter, you will:
- [ ] Have accessed your pre-created workshop repository in the `a-demo-organization` GitHub organization
- [ ] Have opened the repository in GitHub Codespaces (the pre-configured lab environment)
- [ ] Understand the push-to-deploy model used in this workshop
- [ ] Be ready for Terraform fundamentals and hands-on implementation

## Intro Step 1: Access Your Pre-Created Repository (5 min)

Your instructor has already created a repository for you in the `a-demo-organization` GitHub organization. You do not need to fork or create your own—just find it and get started.

**Step 1: Navigate to your repository**

1. Go to **`github.com/a-demo-organization`**
2. Find your pre-created repository — it follows the pattern **`powershell-summit-terraform-workshop-{your-github-username}-{random-letters}`**
3. Open that repository
4. This is your "learner copy" — a full copy of the workshop repo where you'll write code and push changes

**Why:**
- Every push comes from YOUR pre-created repository
- HCP Terraform runs are isolated to your learner copy
- You can safely experiment without affecting others
- Deployment is triggered when you push to `main` in YOUR copy

## Intro Step 2: Open in GitHub Codespaces (5 min)

The lab environment **is** GitHub Codespaces. Everything is pre-configured:
- Terraform CLI
- Azure CLI
- Git
- GitHub Copilot
- HashiCorp Terraform extensions
- HCP Terraform wiring (already connected to your learner copy)

**Step 1: Open your learner copy in Codespaces**

1. Go to your pre-created repository (from Intro Step 1 above)
2. Click **Code** (green button)
3. Click **Codespaces**
4. Click **Create codespace on main**
5. GitHub spins up a full VS Code environment in your browser
6. Wait ~60 seconds for the environment to boot

**Step 2: Verify tools are available**

Once the Codespace is open, open a terminal and run:

```bash
terraform version
az --version
git --version
```

All three should report versions. If any fail, refresh the page and wait another 30 seconds.

**Why Codespaces:**
- No installation friction (everything is pre-configured)
- Same environment for every participant (no "it works on my machine" problems)
- HCP Terraform is already wired to your learner copy
- Your code is safe if your laptop dies

## Intro Step 3: Understand the Deployment Model (3 min)

### Core Workflow for Every Hands-On Chapter

```text
1. Edit Terraform in your learner copy (in Codespaces)
2. Run local checks (fmt, validate)
3. Commit and push to main in your learner copy
4. HCP Terraform automatically runs the plan and apply
5. Review the run results in the HCP UI or Azure portal
```

Use this command sequence repeatedly:

```bash
git add .
git commit -m "lab: update"
git push origin main
```

**After you push:**
- HCP Terraform detects the push to your learner copy's `main` branch
- It automatically runs `terraform plan` to show what will change
- It automatically runs `terraform apply` to deploy changes
- You can review the run output in the HCP Terraform UI
- Resources appear in your Azure resource group

## Quick Readiness Check

Before moving on:
- [ ] You can access your pre-created repository in the `a-demo-organization` GitHub organization
- [ ] You have opened it in GitHub Codespaces
- [ ] Commands run from the repository root in the Codespace
- [ ] `terraform version` succeeds
- [ ] `git --version` succeeds
- [ ] You understand: deployment is triggered by `git push origin main` from your learner copy

---

# Chapter 2: IaC & Terraform Essentials (Compressed)
**Duration:** 5 minutes  
**Objective:** Explain Infrastructure as Code concept and Terraform workflow

## Learning Outcomes

By the end of this chapter, you will:
- [ ] Understand what Infrastructure as Code means
- [ ] Know Terraform's three-step workflow (init, plan, apply)
- [ ] Recognize the key components you'll use today

## What is Infrastructure as Code?

Infrastructure as Code means one thing: **write code that describes your cloud infrastructure, deploy it, change it, delete it—all in code.**

Think of it like this:
- **Without IaC:** Click 50 things in the Azure Portal
- **With IaC:** Run three commands. Done.

And here's the kicker: when your colleague asks "how did you set this up?" Instead of "um, I clicked things," you say "here's the code."

| Aspect | Portal Clicks | Terraform |
|--------|--------------|-----------|
| **Setup time** | 30 minutes of clicking | 5 minutes of typing |
| **Documentation** | Hope someone remembers | Code = documentation |
| **Version control** | None | Full Git history |
| **Repeatability** | Probably made a mistake | Exact same every time |
| **Scale** | 10 environments = 10x clicks | 10 environments = 10x code (with variables) |

## Terraform Workflow: Init → Plan → Apply

**Show this workflow:**

```
┌─────────────────────────────────────────────────┐
│  Your Terraform Code (main.tf)                  │
│  "I want an Azure Storage Account with these    │
│   properties"                                    │
└────────────────┬────────────────────────────────┘
                 │
         ┌────────▼──────────┐
         │  terraform init   │
         │  (Setup)          │
         └────────┬──────────┘
                  │
         ┌────────▼──────────┐
         │ terraform plan    │
         │ (What will       │
         │  change?)        │
         └────────┬──────────┘
                  │
         ┌────────▼──────────┐
         │ terraform apply   │
         │ (Do it!)          │
         └────────┬──────────┘
                  │
         ┌────────▼──────────────────┐
         │ Azure has your resources! │
         └───────────────────────────┘
```

**Explain each step:**
1. **Init:** "Hey Terraform, set up. Look at my code. Get ready."
2. **Plan:** "Show me what you're about to create/change. I want to see it first."
3. **Apply:** "Go ahead. Deploy it. Create the resources."

**Most important phrase:**
> "We ALWAYS do plan before apply. Never apply blindly. It's like 'git diff' but for infrastructure."

## Three Key Components You'll See

Don't worry about memorizing everything. Just recognize these three things:

1. **Providers** (`terraform.tf`) — "This tells Terraform which clouds and tools to use"
   ```hcl
   terraform {
     required_version = ">= 1.14.0, < 2.0.0"

     cloud {
       organization = "a-demo-organization"
       workspaces {}
     }

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
   ```
   > **Note on `workspaces {}`:** The empty block tells HCP Terraform to use the workspace already configured for this repo in the `a-demo-organization` organization. You don't need to name it here — it's pre-wired.

2. **Resources** (`main.tf`) — "These describe what you want to create"
   ```hcl
   resource "azurerm_resource_group" "main" {
     location = var.azure_region
     name     = "workshop-${local.resource_suffix}"

     tags = {
       environment = "workshop"
     }
   }
   ```
   The `local.resource_suffix` comes from a `locals` block that combines two `random` resources — giving each attendee a unique suffix so resource names don't collide.

3. **Variables** (`variables.tf`) — "These let you pass values in so nothing is hardcoded"
   ```hcl
   variable "azure_region" {
     default     = "westus2"
     description = "Azure region for all resources"
     type        = string
   }
   ```

> "That's all you need to know. We'll see these in the next Chapter when we deploy something real. Notice the commented-out blocks in `main.tf` — those are your exercises. You'll uncomment them one at a time."

## Where Does Terraform State Live?

> 📦 In this workshop, state is stored remotely in HCP Terraform — not on your local machine. The `terraform.tf` file in the repo root configures this with a `cloud {}` block pointing to the pre-configured HCP workspace. Remote state means:
>
> - No `terraform.tfstate` file in your repo (it's stored securely in HCP)
> - Multiple team members can run plans without state conflicts
> - State history and locking are handled automatically
>
> You can view the current state in the HCP Terraform UI under your workspace's **States** tab.

---

# Chapter 3: Hands-On - Deploy Your First Resource
**Duration:** 45-50 minutes  
**Objective:** Make your first Terraform change and deploy it through the learner-copy git push workflow

## Learning Outcomes

By the end of this chapter, you will be able to:
- [ ] Update Terraform in the repository root
- [ ] Run local checks (`fmt`, `validate`, `plan`)
- [ ] Commit and push from your learner copy
- [ ] Confirm deployment by reviewing the HCP Terraform run
- [ ] Troubleshoot common first-run issues

## Important Workflow Note

The lab environment is the repository root. HCP Terraform is already preconfigured. Deployment happens from push, not by local `terraform apply`.

> **🔐 How HCP Terraform authenticates to Azure**
>
> This workshop uses a pre-configured HCP Terraform workspace with a service principal credential stored as a workspace environment variable (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`). When you push code, HCP Terraform runs `terraform plan/apply` using these credentials — you never need to configure Azure auth locally.
>
> For production use, HashiCorp recommends OIDC (dynamic credentials) over static service principal secrets. See: [HCP Terraform Dynamic Provider Credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials)

## Part 1: Prepare Your Learner Copy on Main

From the repository root:

```bash
git checkout main
git pull
```

## Part 2: Update Terraform for the First Resource

This exercise uses **Exercise 1: Storage Account** — the commented block already in `main.tf`.

Checklist:
- [ ] Uncomment the `azurerm_storage_account` block in `main.tf`
- [ ] Uncomment the `storage_account_name` output in `outputs.tf`
- [ ] Update `workspaces` with the name equal to your GitHub user name in `terraform.tf`
- [ ] Keep names and variables aligned with workshop naming guidance

Tip:
- The naming module already generates a unique storage account name — no manual suffix needed.

## Part 3: Run Local Safety Checks

Run these from repository root:

```bash
# first log in to our workspace
terraform login

terraform init
terraform fmt
terraform validate
terraform plan
```

**Troubleshooting**

If `terraform login` doesn't seem to authenticate, you can set `$env:TF_TOKEN_app_terraform_io` and `$env:TF_TOKEN_APP_TERRAFORM_IO` to the token value.

What to look for:
- `init` initializes the HCP Terraform backend — required once per Codespace session
- `fmt` makes style consistent
- `validate` confirms configuration is structurally correct
- `plan` confirms only expected resources are changing

If `plan` shows unexpected deletes, stop and review before pushing.

## Part 4: Deploy by Commit and Push

```bash
# See what files have changed
git status

# We should be able to add all the changes
git add .
git commit -m "lab: chapter 3 first resource"
git push origin main
```

Workshop rule:
- Deployment is triggered by push to `main` in your learner copy.

## Part 5: Verify the HCP Terraform Run

After push:
- Open the run in HCP Terraform
- Confirm run status reaches `Applied` (or expected plan-only status)
- Review outputs for resource identifiers
- Confirm resources in Azure portal under the expected workshop deployment context

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

## Quick Verification Checklist

Before moving on:

**Exercise 1: Storage Account**
- [ ] Ran `terraform fmt`, `terraform validate`, and `terraform plan`
- [ ] Committed and pushed from learner copy
- [ ] Saw HCP run trigger from push
- [ ] Confirmed expected resource outcome

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
| `azurerm_network_interface` | NIC connecting VM to subnet and public IP |
| `azurerm_network_interface_security_group_association` | Links the NIC to the NSG |
| `random_password.vm_admin` | Generates a secure admin password |
| `azurerm_windows_virtual_machine` | Windows Server 2022 Datacenter VM (**Standard_D2_v4** — Intel SKU) |
| `azurerm_virtual_machine_extension.iis` | Installs IIS via CustomScriptExtension |

> ⚠️ **Workshop-only configuration:** The NSG in this exercise allows inbound HTTP (port 80) from any source (`*`). This is intentional for the workshop so you can verify IIS is running. In production, restrict `source_address_prefix` to known IP ranges and enable HTTPS.

> ⚠️ **Azure VM SKU Selection for Windows:** Always use D-series v4 SKUs for Windows VMs for optimal performance and cost efficiency. The workshop uses `Standard_D2_v4` (Intel, v4 generation). Reference: [Azure VM Sizes — D-series v4](https://learn.microsoft.com/en-us/azure/virtual-machines/dv4-dsv4-series)

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

# Chapter 4: Deploy with Azure Verified Modules
**Duration:** 20-25 minutes  
**Objective:** Replace handwritten resource blocks with AVM patterns while keeping the same push-based deployment loop

## Learning Outcomes

By the end of this chapter, you will:
- [ ] Understand why AVM is preferred for common Azure resources
- [ ] Update the lab configuration to use AVM inputs
- [ ] Validate locally and deploy by pushing to `main`
- [ ] Verify results in HCP Terraform and Azure

## Why This Chapter Matters

Chapter 3 taught the workflow. Chapter 4 upgrades implementation quality. You keep the same loop (edit, validate, push) but adopt Azure Verified Modules for safer defaults and less boilerplate.

## Part 1: Understand the Shift

Handwritten blocks are useful for learning, but AVMs are preferred for common Azure services because they:
- encode proven defaults
- reduce repetitive boilerplate
- improve consistency across teams

## Part 2: Add the AVM Storage Module

The AVM exercise is not a commented block — you add it directly. Copy the blocks below into the appropriate files.

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
  shared_access_key_enabled = true

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

## Part 4: Deploy by Push From Learner Copy

```bash
git add .
git commit -m "lab: chapter 4 avm deployment"
git push origin main
```

Workshop rule:
- Deployment is triggered by push to `main` in your learner copy.

## Part 5: Verify Results

In HCP Terraform:
- Open the run triggered by your push
- Confirm run status and resource actions
- Review outputs

In Azure portal:
- Confirm resources under the expected workshop deployment context
- Validate expected configuration (for example HTTPS-only and naming/tag conventions)

## Troubleshooting

### Module source/version issue
- Rerun `terraform init`, check module source/version, recommit if needed.

### Name collision
- Update name variable, rerun plan, commit, push.

### Run failed in HCP
- Fix from run logs, then push follow-up commit.

---

# Chapter 5: Copilot and MCP
**Duration:** 25-30 minutes  
**Objective:** Use GitHub Copilot with Terraform MCP Server to write infrastructure code at high velocity

## Learning Outcomes

By the end of this Chapter, you will:
- [ ] Understand what MCP (Model Context Protocol) is
- [ ] Use Copilot Chat to author Terraform code
- [ ] Use Terraform MCP Server to look up module details, versions, and best practices
- [ ] See how AI speeds up IaC authoring
- [ ] Write reusable patterns with Copilot

## What is MCP? (Ultra-Compressed)

**One sentence:**
> "MCP connects AI tools (like Copilot) to domain tools (like HCP Terraform and the Terraform Registry). So Copilot can retrieve live module data and best practices, not just suggest them."

**Three examples:**
1. You ask Copilot: "What inputs does the AVM storage account module accept?"
2. Copilot queries the Terraform Registry and shows you the actual module documentation
3. You get definitive answers backed by live registry data, not guesses

**The result:** Copilot goes from "I think the module works like this" to "Here's what the module actually does, straight from the Terraform Registry."

## Live Demo: Use Copilot to Write Terraform

### **Scenario: Add a Database to Your Project**

Imagine we want to add an Azure SQL Database to our infrastructure. Instead of writing it from scratch, we'll use Copilot.

### **Step 1: Open Copilot Chat**

In VS Code (your Codespace):
1. Click the **Copilot Chat icon** (left sidebar, looks like a speech bubble)
2. Or press `Ctrl+Shift+I` (Windows) / `Cmd+Shift+I` (Mac)

**Copilot Chat is now ready.**

### **Step 2: Ask Copilot to Generate Terraform**

**In Copilot Chat, type:**

```
I'm using Terraform with Azure. I want to add a SQL Database to my 
infrastructure. Give me Terraform code using the Azure Verified Module 
for SQL Server. Use variables for server name, database name, and admin password.
```

**Click Send.**

**What Copilot does:**
1. Reads your message
2. Understands you want Terraform + Azure SQL + AVM
3. Generates code with the right module, variables, outputs

**Expected output:** Copilot gives you ~40-50 lines of ready-to-use code.

### **Step 3: Review the Code**

Copilot outputs something like:
```hcl
module "sql_database" {
  source = "Azure/avm-res-sql-server/azurerm"
  version = "0.2.0"

  location            = var.location
  resource_group_name = var.resource_group_name
  server_name         = var.sql_server_name
  administrator_login = var.admin_username
  # ... more config
}
```

**Talk through it:**
- "See? AVM for SQL. Best practices built-in."
- "It's asking for inputs via variables—exactly what we want."
- "No boilerplate. Just the essential config."

### **Step 4: Copy Code into Your Project**

Click the **copy button** in Copilot's response.

Paste into `main.tf`.

### **Step 5: Ask Copilot to Generate Variables**

**In Copilot Chat, type:**

```
Now write the variables for this SQL module. Include descriptions 
and sensible defaults where possible.
```

Copilot generates `variables.tf` entries. Copy them into `variables.tf`.

### **Step 6: Validate with Terraform**

Now the real magic. In terminal:

```bash
# terraform init because we added a new module
terraform init
terraform validate
```

**Two outcomes:**

**A) "Success!" (most likely)**
> "Terraform says your code is syntactically correct. No typos, no missing pieces."

**B) "Error: ..." (less likely)**
> "Terraform found an issue. Most common: wrong variable name, missing required input."

**If error:**

**In Copilot Chat:**
```
I got this Terraform error:
[paste the error]

Can you fix the code?
```

Copilot reads the error and provides a corrected version. Copy it back in.

## Copy-Paste Prompts You Can Reuse

These prompts work in Copilot Chat for Terraform generation:

### **Prompt 1: Generate a New Resource**
```
I want to add a {RESOURCE_TYPE} to my Terraform project.
Use the Azure Verified Module if available.
Make it production-ready with encryption and monitoring enabled.
Generate the code with variables for {KEY_PARAMETERS}.
```

### **Prompt 2: Convert Portal Config to Terraform**
```
I manually created a {RESOURCE_TYPE} in Azure. Here's its config:
[paste properties from portal]

Write Terraform code to recreate this resource using an AVM.
```

### **Prompt 3: Add Security Best Practices**
```
Here's my Terraform code:
[paste code]

What security best practices am I missing?
How do I improve it? Rewrite with improvements.
```

### **Prompt 4: Explain Error**
```
I got this Terraform error:
[paste error]

What went wrong? How do I fix it?
```

## Terraform MCP Server: Installation and Setup

**What is the Terraform MCP Server?**

It's a bridge that lets Copilot query HCP Terraform and the Terraform Registry to retrieve live module metadata and documentation. Not just suggest—actually look up module definitions, find current versions, and share best practices.

### Installing and Configuring the MCP Server

Before you can use MCP with Copilot, you must set it up. This is a one-time configuration per repository.

**Step 1: Create the MCP Configuration File**

In the repository root (where `main.tf` is located), create a new folder called `.vscode` if it doesn't exist. Then create a file named `mcp.json` inside `.vscode/`:

**File:** `.vscode/mcp.json`

```json
{
  "servers": {
    "terraform": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "TFE_TOKEN=${input:tfe_token}",
        "-e", "TFE_ADDRESS=${input:tfe_address}",
        "hashicorp/terraform-mcp-server:0.5.1"
      ]
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "tfe_token",
      "description": "Terraform API Token",
      "password": true
    },
    {
      "type": "promptString",
      "id": "tfe_address",
      "description": "Terraform Address",
      "password": false
    }
  ]
}
```

This configuration:
- Runs the Terraform MCP server in a Docker container for consistency and portability
- Uses `${input:tfe_token}` and `${input:tfe_address}` to prompt for credentials on first use
- Use `https://app.terraform.io` as the value for `tfe_address`
- Passes credentials securely as environment variables to the server

**Exact location:**
- Repository root
  - `.vscode/` (folder)
    - `mcp.json` (file you just created)

### Step 2: Verify the File Location

After creating the file, verify it's in the right place:

```bash
# From the repository root:
ls -la .vscode/mcp.json
```

You should see the path in the output. If it's not there, you created it in the wrong location.

### Step 3: Verify MCP is Running

The MCP server will automatically start when Copilot first uses it, or you can start it manually from the editor window. No restart needed.

Open Copilot Chat by pressing `Ctrl+Shift+I`. Type this test command:

```
What inputs and outputs does the Azure storage account AVM module provide?
```

**Expected response:**
- Copilot connects to the Terraform Registry
- You see the actual inputs, outputs, and resources created by the module

**If you see "I can't access that":**
- Verify the `.vscode/mcp.json` file exists and contains the exact JSON above
- Check that `.vscode/mcp.json` is in the repository root, not a subdirectory
- Try asking Copilot again—the MCP server starts automatically on first use
- Add a specific direction in the prompt to use the MCP server or ask why it did not use it.

### Troubleshooting MCP Setup

| Problem | Cause | Fix |
|---------|-------|-----|
| "I can't access the registry" | MCP server hasn't started yet | Verify the `.vscode/mcp.json` file exists and has correct syntax. Try asking Copilot again—the MCP server starts automatically on first use. |
| "Docker not found" | Docker daemon is not running or Docker not installed | Ensure Docker Desktop is running. Codespaces includes Docker. If missing, rebuild Codespace. |
| `.vscode/mcp.json` created but ignored | File in wrong location | Move it to repository root (same level as `main.tf`). |
| Registry queries are slow | Network latency or Registry service response | Queries depend on network speed. Retry if a single query is slow. |

---

## Terraform MCP Server Validation

### Demo: See the MCP Difference in Action (5 min)

This is the "aha moment" where attendees see MCP's real power.

#### **The Setup: Terraform Files in Your Repo**

You have `.tf` files in your project. Let's use MCP to understand them better than Copilot could without MCP.

#### **Without MCP (Static File Analysis)**

If Copilot only had the HCL files in your workspace, it would say something like:

```
"I see you have a storage account module, but I can't tell you:
- What inputs it actually accepts (I'd have to guess)
- What resources it creates (I'd have to read the module source code)
- Whether your config will work (I can't validate against the provider)"
```

#### **With MCP (Four Specific Capabilities)**

Now ask Copilot:

**Prompt:**
```
Check my Terraform configuration for errors and tell me what 
resources will be created. Also, what are the required inputs 
for the AVM storage account module I'm using?
```

**Copilot (with MCP) responds with:**
1. ✅ **Check Module Resources & Properties:** Looks up the Azure storage account module in the Terraform registry and retrieves its actual inputs, outputs, and the resources it creates (e.g., storage account, network rules, encryption)
2. ✅ **Version Lookup:** Retrieves the latest available versions of modules and providers from the Terraform Registry
3. 📋 **HCP Terraform Integration:** Can interact with HCP Terraform workspaces to check runs and state (if credentials are configured)
4. 📚 **Best Practices:** Retrieves Terraform documentation and recommended configurations from the Terraform documentation

**The difference:** Copilot went from "I think..." to "Here's what the registry actually says, with current versions and official best practices."

#### **Try It Now (Live Demo)**

1. Open your Terraform files in the workspace
2. In Copilot Chat, paste this prompt:

```
I'm using the Azure storage account AVM. Can you:
1. Show me what inputs and outputs this module provides
2. Tell me the latest available versions of the azurerm provider and this module
3. Explain best practices for configuring storage accounts in Terraform
4. Describe what resources this module creates
```

3. Watch Copilot connect to MCP and:
   - **Check module resources & properties** — pulls the actual module definition from the Terraform registry
   - **Get module inputs & outputs** — queries the registry for detailed parameter information
   - **Find current versions** — looks up the latest stable version of modules and providers
   - **Show documentation** — retrieves best practices and usage examples from the registry
4. Compare what MCP shows you (live module data, documentation, version info) vs. what static file reading could show (guesses and assumptions)

---

## Summary of MCP Capabilities

The Terraform MCP Server enables Copilot to:
1. **Interact with HCP Terraform** — manage workspaces, check runs, view state
2. **Get details of modules and resources from the Terraform Registry** — look up module inputs, outputs, resources, and providers
3. **Find the most current versions** of modules and providers from the registry
4. **Get documentation and best practices** from Terraform documentation

In this workshop, use these capabilities to understand your infrastructure code better before pushing to deploy.

---

## Chapter 6: Skills & Knowledge Management

## The Velocity Play

**Without Copilot + MCP:**
1. Write Terraform code (20-30 min)
2. Test locally (5 min)
3. Read errors (10 min)
4. Fix and re-test (15 min)
5. **Total: ~50+ minutes**

**With Copilot + MCP:**
1. Describe what you want in chat (2-3 min)
2. Copilot writes code (instant)
3. Validate with MCP (2 min)
4. Deploy (5 min)
5. **Total: ~10-12 minutes**

**We literally ship 5x faster.**

---

# Chapter 6: Skills & Knowledge Management
**Duration:** 25-30 minutes  
**Objective:** Create reusable skills that encapsulate IaC patterns and persist across sessions

## Learning Outcomes

By the end of this Chapter, you will be able to:
- [ ] Understand skills as documented patterns and best practices
- [ ] Master the SKILL.md format and structure
- [ ] Create 1-2 team-specific Azure/Terraform skills
- [ ] Version and evolve skills over time
- [ ] Integrate skills with agents and MCP servers
- [ ] Share skills with teams

## What Are Skills?

**A SKILL is:**
- A documented solution to a common problem
- Version controlled (in git)
- Reusable across projects
- Known by your AI agents
- Evolved by your team over time

**Not:**
- Code libraries (use modules for that)
- Documentation (though it's documented)
- One-time solutions

### Examples

**Skill: "Deploy a Web API to Azure App Service"**
- When should you use this pattern?
- What Azure resources do you need?
- What Terraform code implements it?
- What security considerations matter?
- What monitoring should be enabled?
- Cost ballpark?
- Team approval workflow?

**Skill: "Implement network security baseline"**
- NSG rules for common scenarios
- Private endpoint setup
- Firewall configuration
- Audit logging
- Compliance checklist

### Why Skills Matter

| Without Skills | With Skills |
|---|---|
| "Everyone designs networking differently" | "Here's THE network pattern we use" |
| "Why did we set up logging this way?" | "See Skill#3: Logging and Monitoring" |
| "Can new hires learn our patterns?" | "Read the skills folder, understand patterns" |
| "How do we enforce standards?" | "Agent enforces skills in code review" |
| "Where's the documentation?" | "In git, version controlled, always current" |

## Skill Anatomy - SKILL.md Format

### Anatomy of a SKILL.md File

```markdown
# Skill: {Name}
**ID:** skill-{kebab-case-name}  
**Version:** 1.0  
**Author:** {Your Team}  
**Status:** ✅ Production  
**Last Updated:** 2025-03-31

---

## What This Skill Solves
Clear problem statement. When would you use this?

## Problem Statement
Specific challenge the skill addresses.

## Solution Architecture
High-level design (diagrams, conceptual).

## Resources Created
What Azure resources does this pattern create?

## Terraform Implementation
Complete, working code.

## Related Skills
Links to complementary skills.

## Cost Estimation
Rough monthly cost.

## Security Checklist
Security best practices for this pattern.

## Monitoring & Alerts
What should you monitor?

## Troubleshooting
Common issues and fixes.

## Team Notes
Lessons learned, advice.

## References
External documentation, Microsoft Learn links.
```

### Example Skill: Deploy Multi-Tier App

Here's a real example:

```bash
mkdir -p skills/deploy-multi-tier-app
cat > skills/deploy-multi-tier-app/SKILL.md << 'EOF'
# Skill: Deploy Multi-Tier Application to Azure

**ID:** skill-deploy-multi-tier-app  
**Version:** 1.1  
**Status:** ✅ Production  
**Author:** Infrastructure Team  
**Updated:** 2025-03-31

---

## What This Skill Solves

You need to deploy an application with multiple tiers:
  - **Presentation Tier:** Web/API exposed to users
  - **Business Logic Tier:** Processing and business rules
  - **Data Tier:** Database and caching

Examples:
  - Web frontend + API backend + SQL database
  - Web app + Azure Functions + Cosmos DB
  - REST API + microservices + Postgres

This skill provides a reference architecture and Terraform code.

---

## Problem Statement

Without a standard pattern, teams often:
  ❌ Put everything in one subnet (security risk)
  ❌ Don't replicate databases (no HA)
  ❌ Skip monitoring (can't debug)
  ❌ Hardcode connection strings (security issue)
  ❌ Forget about scaling (performance issues)

---

## Solution Architecture

```
┌────────────────────────────────────────────────┐
│             VNet (10.0.0.0/16)                 │
├────────────────────────────────────────────────┤
│                                                │
│  ┌─────────────────────────────────────────┐  │
│  │  Public Subnet (10.0.1.0/24)            │  │
│  │  - App Gateway (ingress)                │  │
│  │  - Application Insights                 │  │
│  └─────────────────────────────────────────┘  │
│           ↓ (private to app subnet)            │
│  ┌─────────────────────────────────────────┐  │
│  │  App Subnet (10.0.2.0/24)               │  │
│  │  - App Service (web/API)                │  │
│  │  - Auto-scaling enabled                 │  │
│  │  - Health probes active                 │  │
│  └─────────────────────────────────────────┘  │
│           ↓ (private endpoint)                 │
│  ┌─────────────────────────────────────────┐  │
│  │  Data Subnet (10.0.3.0/24)              │  │
│  │  - SQL Database (private endpoint)      │  │
│  │  - Redis Cache (private endpoint)       │  │
│  │  - Storage Account (private endpoint)   │  │
│  └─────────────────────────────────────────┘  │
│                                                │
└────────────────────────────────────────────────┘
```

**Key Patterns:**
  - Subnets isolate each tier (network segmentation)
  - Private endpoints prevent internet exposure
  - Application Gateway routes public traffic
  - Secrets stored in Key Vault (not in code)

---

## Security Checklist

- [ ] **Network Isolation:** Resources in private subnets (no public IPs)
- [ ] **Secrets:** Connection strings in Key Vault, not hardcoded
- [ ] **Encryption:** TLS for all traffic, encryption at rest
- [ ] **Authentication:** SQL auth + Azure AD
- [ ] **Firewall:** Network Security Groups (NSGs) restrict access
- [ ] **Monitoring:** All access logged to Log Analytics
- [ ] **Update Policy:** Auto-patching enabled for SQL
- [ ] **Backup:** Daily automated backups configured
- [ ] **Compliance:** Meets your regulatory requirements

---

## Monitoring & Alerts

**Set up these alerts:**

1. **Application Availability**
   - Alert if app response time > 3s
   - Alert if error rate > 1%

2. **Database Performance**
   - Alert if CPU > 80%
   - Alert if DTU usage > 80%
   - Alert if deadlocks occur

3. **Network Issues**
   - Alert on failed connections
   - Alert on DoS patterns

4. **Cost**
   - Alert if bill > 20% over budget

---

## Troubleshooting

### "App can't connect to database"
Causes:
  - Firewall rule too restrictive
  - Connection string incorrect
  - Database credentials wrong

Fix:
  1. Check firewall allows app subnet
  2. Use Key Vault for connection string
  3. Test credentials in SQL Server Management Studio

---

## Team Notes

**Lessons Learned:**
- Private endpoints add latency (~2-3ms) but gain security
- Redis caching multiplies app throughput 5-10x
- Log retention costs dominate monitoring budget; set retention to 30 days

**Team Standards for This Pattern:**
- All databases must have private endpoints (no exceptions)
- All connection strings come from Key Vault
- All resources must have Environment and Owner tags

---

## References

- [Azure App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Azure SQL Database Architecture](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-database-overview)
- [Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Azure Architecture Framework](https://learn.microsoft.com/en-us/azure/architecture/)

---

**How to Use This Skill:**

When someone asks "How do we deploy a web app on Azure?", point them here.
When you're designing a new project, use this as a starting point.
When an agent is helping, point them to this skill file.

Version this skill in git. Update it as your team learns.
EOF
```

### That's a complete Skill!

The skill:
  ✅ Explains the problem
  ✅ Shows the architecture
  ✅ Gives cost estimates
  ✅ Documents security requirements
  ✅ Lists related skills
  ✅ Provides troubleshooting
  ✅ Is version controlled

## Create a Second Skill - Network Security Baseline

Create another skill for security practices. Follow the same template and focus on:
- Network Security Group rules
- Default-deny approach
- Audit logging
- Compliance baseline

## Version Control Skills

```bash
# Commit skills to git
git add skills/
git commit -m "docs: Add Terraform skills library (multi-tier, security-baseline)"

# Share with team
git push origin main

# Everyone now has access to these skills!
```

### Evolve Skills

As your team learns:

```bash
# After you discover a better approach, update the skill
nano skills/deploy-multi-tier-app/SKILL.md

# Bump the version
# OLD: **Version:** 1.0
# NEW: **Version:** 1.1

# Add a "What Changed" section
# Commit and push

git add skills/
git commit -m "docs: Update multi-tier skill v1.1 - add Redis caching"
git push
```

---

# Chapter 7: Copilot Customization — Instructions and Custom Agents
**Duration:** 30-35 minutes *(beyond the 140-165-minute core path)*

> ⏱️ **Stretch Goal** — This chapter is optional. Complete it if you have time remaining after Chapter 6. If not, proceed directly to [Chapter 8: Wrap Up](./08_Wrap_Up.md).

## Learning Outcomes

By the end of this chapter, you will be able to:
- [ ] Explain the three ways to customize Copilot's behavior in VS Code: repo-wide instructions, scoped instructions, and custom agents
- [ ] Distinguish between *passive* instruction files (always-on context injection) and *active* agent files (invokable modes in the Chat panel)
- [ ] Read and understand `.github/copilot-instructions.md` and explain when it applies
- [ ] Describe how `.github/instructions/*.instructions.md` files scope context to specific file patterns
- [ ] Read and understand an `.agent.md` file and its frontmatter fields
- [ ] Explain what the `tools` field controls and what values are available
- [ ] Create a custom agent file in `.github/agents/` for this workshop's Terraform workflows
- [ ] Invoke your custom agent via the VS Code Copilot Chat agent picker
- [ ] Confirm the agent appears and behaves as configured

## The Three Ways to Customize Copilot

### The Problem

Every Copilot Chat session starts fresh. Without customization:
- Copilot doesn't know your naming conventions
- It doesn't know you prefer Azure Verified Modules
- It doesn't know you're constrained to resource-group scope
- It doesn't know to run `terraform validate` before `terraform apply`

You re-explain the context every session. The three customization files solve this — each in a different way.

---

### File Type 1: `.github/copilot-instructions.md` — Repo-Wide, Always-On

This file injects instructions into **every** Copilot Chat conversation in the repository. It's passive — Copilot reads it automatically, no action required from the user.

**When it applies:** Every chat session opened in this repo, for every user, for every file type.

**What it's for:** Project-wide rules that always apply — architecture decisions, coding conventions, security constraints.

Open it and look — it tells Copilot to prefer Azure Verified Modules, run `terraform fmt` before `apply`, use resource-group scope only, and never hardcode secrets. Every time anyone opens Copilot Chat in this repo, those rules are already loaded.

> 📌 **Key point:** This file creates no named agent. It is not invokable. It simply injects context into every conversation, silently, in the background.

---

### File Type 2: `.github/instructions/*.instructions.md` — Scoped, Pattern-Based

These files also inject context automatically, but only when the files matching a glob pattern are open or active in the editor. You define the scope in the file's YAML frontmatter.

**Example frontmatter:**

```yaml
---
applyTo: "**/*.tf"
---
Always prefer Azure Verified Modules. Never hardcode secrets or tenant IDs.
```

With this file in `.github/instructions/terraform.instructions.md`, Copilot automatically adds the scoped instructions whenever a `.tf` file is the active context — and ignores them otherwise.

**When to use this vs `copilot-instructions.md`:**

| | `copilot-instructions.md` | `instructions/*.instructions.md` |
|--|--|--|
| Scope | Always applies | Only when matching files are open |
| Use for | Project-wide rules | Language/technology-specific rules |
| Invokable by user? | No | No |

> 📌 **Key point:** Like `copilot-instructions.md`, these files are **passive**. They inject context automatically based on file patterns. They do not create named agents or appear in any picker.

---

### File Type 3: `.github/agents/*.agent.md` — Active, Invokable Agents

This is the big one. An `.agent.md` file defines a **named Copilot Chat mode** — a specialized AI persona that the user explicitly selects in the Chat panel.

**How it works:**
1. You create `.github/agents/my-agent.agent.md`
2. VS Code detects the file automatically
3. The agent appears in the **agent picker** in the Copilot Chat panel
4. The user opens Copilot Chat and clicks the agent selector (`@` or the mode dropdown) to pick it

**How to invoke:** Open Copilot Chat (`Ctrl+Alt+I`), then click the agent selector at the top of the panel. Your agent appears there by name. Select it — all subsequent messages in that session run through the agent's system prompt.

> 📌 **Key point:** This is the only customization type the user actively selects. Instructions files are passive context; agent files are invokable modes.

---

### Summary: Passive vs Active

| File | Mechanism | Invoked by user? | Appears in Chat UI as |
|------|-----------|------------------|-----------------------|
| `.github/copilot-instructions.md` | Auto-injected every session | No | Invisible background context |
| `.github/instructions/*.instructions.md` | Auto-injected when file pattern matches | No | Invisible background context |
| `.github/agents/*.agent.md` | User selects from Chat agent picker | **Yes** | Named mode in agent selector |

---

## Anatomy of an `.agent.md` File

### The Format

An `.agent.md` file has YAML frontmatter followed by a system prompt in markdown. Here is an example:

```yaml
---
name: Terraform Azure Architect
description: "Use when designing, reviewing, or refactoring Azure Terraform with Azure Verified Modules, HCP Terraform, GitHub Copilot, or resource-group-scoped deployment workflows."
tools: [execute, read, edit, search, terraform/attach_policy_set_to_workspaces, terraform/attach_variable_set_to_workspaces, terraform/create_run, terraform/create_variable_in_variable_set, terraform/create_variable_set, terraform/create_workspace, terraform/create_workspace_tags, terraform/create_workspace_variable, terraform/delete_variable_in_variable_set, terraform/detach_variable_set_from_workspaces, terraform/get_apply_details, terraform/get_apply_logs, terraform/get_latest_module_version, terraform/get_latest_provider_version, terraform/get_module_details, terraform/get_plan_details, terraform/get_plan_json_output, terraform/get_plan_logs, terraform/get_policy_details, terraform/get_private_module_details, terraform/get_private_provider_details, terraform/get_provider_capabilities, terraform/get_provider_details, terraform/get_run_details, terraform/get_stack_details, terraform/get_token_permissions, terraform/get_workspace_details, terraform/list_runs, terraform/list_stacks, terraform/list_terraform_orgs, terraform/list_terraform_projects, terraform/list_variable_sets, terraform/list_workspace_policy_sets, terraform/list_workspace_variables, terraform/list_workspaces, terraform/read_workspace_tags, terraform/search_modules, terraform/search_policies, terraform/search_private_modules, terraform/search_private_providers, terraform/search_providers, terraform/update_workspace, terraform/update_workspace_variable]
argument-hint: "Describe the Azure resource or Terraform change you want help with."
user-invocable: true
---
```

### Frontmatter Field Reference

| Field | What It Does |
|-------|-------------|
| `name` | The display name that appears in the agent picker |
| `description` | Shown in the selector; helps users understand when to use it |
| `tools` | Which Copilot tools the agent can use (see below) |
| `argument-hint` | Placeholder text shown in the chat input when the agent is selected |
| `user-invocable` | `true` makes it appear in the agent picker for users |

### The `tools` Field

| Value | What It Allows |
|-------|---------------|
| `read` | Read files in the workspace |
| `edit` | Create and edit files |
| `search` | Search the codebase and web |
| `execute` | Run terminal commands |

> ⚠️ **Important:** Only include the tools your agent actually needs. A read-only reviewer needs `[read, search]`. An agent that scaffolds files needs `[read, edit, search]`. Add `execute` only if you need terminal commands (like running `terraform validate`). Fewer tools = less risk.

We've also added the Terraform MCP server tools to allow our expert access to them.

### Below the Frontmatter

Everything below the closing `---` is the **system prompt** — the persistent instructions Copilot follows whenever this agent mode is active. This is where you define:
- The agent's role and expertise
- Constraints (what it should never do)
- Preferred patterns and modules
- Output format expectations

---

## Hands-On — Create Your Own Agent

You will create a focused **security review** agent — an agent whose sole job is to look at Terraform code and flag security issues.

> 🗂️ **Workshop rule:** Create this file in `.github/agents/`. That's the team-shared location. VS Code will detect it automatically.

### Step 1 — Create the agent file

In the Explorer panel (or terminal), create:

```
.github/agents/terraform-security-reviewer.agent.md
```

### Step 2 — Write the frontmatter

Open the file and add:

```yaml
---
name: Terraform Security Reviewer
description: "Reviews Terraform files for security issues: hardcoded secrets, open NSGs, public IPs, missing tags, and insecure defaults."
tools: [read, search, terraform/search_modules, terraform/get_module_details]
argument-hint: "Paste or open the Terraform file you want reviewed."
user-invocable: true
---
```

> **Note:** This agent includes `read` and `search` for code analysis, plus `terraform/search_modules` and `terraform/get_module_details` to look up module information when verifying module security. It does not write or run commands. Keep the `tools` list minimal.

### Step 2a (Optional) — Enhance Your Agent with a Skill

Before writing the system prompt, consider whether this agent should reference a **skill** — a reusable prompt file that provides domain-specific expertise.

**What's a skill?** A skill is a markdown file (typically in `.github/copilot/skills/` or a similar location) that documents specialized knowledge, workflows, or checklists. Instead of embedding all your expertise in the agent's system prompt, you create a skill file and reference it from the agent. This keeps the agent lean and the skill reusable across multiple agents.

**Why use a skill for this agent?** Your security reviewer checks six categories of issues. That's a lot of detail for a system prompt. By pulling those checks into a separate `terraform-security-checklist.md` skill file, you can:
- Keep the agent's instructions focused (the agent stays 15-20 lines, not 50+)
- Reuse the same checklist across other agents (a compliance auditor, a cost optimizer, etc.)
- Update the checklist without restarting the agent or rebuilding anything — just edit and save

**Option: Create a skill file**

If you want to practice this pattern, create `.github/copilot/skills/terraform-security-checklist.md`:

```markdown
# Terraform Security Checklist

This skill defines the security checks performed by the Terraform Security Reviewer agent and other security-focused tools.

## Security Categories

### 1. Hardcoded Credentials
- Look for secret strings, passwords, tokens, API keys, or connection strings in `.tf` files or variable `default` values
- Risk: Secrets in version control are exposed to anyone with repo access; attackers can use them to pivot into infrastructure
- Fix: Use Azure Key Vault, environment variables, or GitHub secrets; never store plaintext secrets in code

### 2. Overly Permissive Network Access
- Flag NSG rules, security group rules, or firewall rules that allow inbound traffic from `0.0.0.0/0` or `::/0`
- Special attention to management ports: SSH (22), RDP (3389), WinRM (5985), SQL (1433), PostgreSQL (5432)
- Risk: Exposed management ports allow brute-force attacks and unauthorized access
- Fix: Restrict source IPs to known ranges; use bastion hosts or private endpoints for remote access

### 3. Public IP Exposure
- Identify resources assigned public IPs that don't explicitly need them
- Risk: Public IPs increase the attack surface; if not properly secured, they expose infrastructure to internet scanning and attacks
- Fix: Use private IPs and route through NAT gateways, load balancers, or application gateways

### 4. Missing Required Tags
- Check that all resources include `environment` and `workshop` tags (project-specific; adjust as needed)
- Risk: Untagged resources are harder to audit, manage, and bill; they may violate compliance policies
- Fix: Add tags to all resources; use a tagging strategy document to keep tags consistent

### 5. Insecure Service Defaults
- Flag `admin_enabled = true` on container registries, unencrypted storage accounts, HTTP endpoints, and weak authentication settings
- Risk: Insecure defaults often remain unnoticed, creating hidden vulnerabilities
- Fix: Explicitly set secure defaults (`admin_enabled = false`, `https_only = true`, encryption enabled)

### 6. Missing Encryption or Access Logging
- Look for storage accounts, databases, or key management without encryption or audit logging enabled
- Risk: Data breaches or compliance violations go undetected
- Fix: Enable encryption at rest and in transit; enable diagnostic logging for all resources

## Response Format

When applying this checklist:
1. State which file you are reviewing
2. For each issue found, include the exact line number(s), the risk description, and a corrected code snippet
3. Organize findings by category (e.g., "Hardcoded Credentials: 1 issue found")
4. If the file passes all checks, say so explicitly with a summary of what was verified
```

Then, in your agent's system prompt (Step 3, below), reference the skill like this:

```markdown
You have access to the Terraform Security Checklist skill at `.github/copilot/skills/terraform-security-checklist.md`. 
Use this skill as your authoritative source for what to check and how to report findings.
```

This approach keeps your agent modular and your checks maintainable. You can extend the checklist over time without modifying the agent itself.

### Step 3 — Write the system prompt

Below the closing `---`, add:

```markdown
# Terraform Security Reviewer

You are a focused Azure Terraform security reviewer. Your only job is to read Terraform files and identify security issues.

## What You Check

1. **Hardcoded credentials** — secrets, passwords, tokens, or keys in `.tf` files or variable defaults
2. **Overly permissive NSG rules** — any rule opening ports to `0.0.0.0/0` or `::/0`, especially management ports (22, 3389, 5985)
3. **Public IP exposure** — resources assigned public IPs that do not explicitly need them
4. **Missing required tags** — resources lacking `environment` and `workshop` tags
5. **Admin features enabled** — `admin_enabled = true` on container registries, weak auth settings
6. **Insecure defaults** — `public_network_access_enabled = true`, unencrypted storage, HTTP endpoints

## How You Respond

For every file you review:
- State which file you are reviewing
- List each issue found with: the exact line(s), the risk, and a corrected code snippet
- If nothing is found, say so explicitly with a brief summary of what was checked

## Constraints

- Do not suggest changes to logic, naming, or formatting unless they are directly related to a security issue
- Do not run commands — you read and analyze only
- Do not make assumptions about intent; report what you observe
```

### Step 4 — Save and invoke the agent

1. Save the file
2. Open VS Code Copilot Chat (`Ctrl+Alt+I`)
3. Click the **agent selector** at the top of the Chat panel (the `@` button or mode dropdown)
4. Confirm **"Terraform Security Reviewer"** appears in the list
5. Select it
6. Open `main.tf` in the editor and type: `Review this file`

Expected: The agent responds as the security reviewer, checking the file against its checklist and reporting findings.

> **Debrief point:** The agent required zero code. It's a markdown file. The system prompt IS the agent. Edit the file and save — VS Code picks up the change immediately, no restart needed.

---

## How the Three Files Work Together

Now you can see how all three customization types stack:

1. **`.github/copilot-instructions.md`** — always-on; loads for every session, every user, every file. Establishes the baseline project context.
2. **`.github/instructions/*.instructions.md`** — loads automatically when matching files are open; adds technology-specific context on top.
3. **`.github/agents/*.agent.md`** — user selects it from the Chat panel; takes over with a specialized persona and restricted toolset.

When you're in the Terraform Security Reviewer agent, _all three layers are active at once_: the repo-wide instructions, any matching scoped instructions, plus the agent's own system prompt.

---

## Skills & Agents: A Powerful Combination

Now that you've built an agent, it's worth understanding how **skills** (from Chapter 6) complement agents and make them more powerful.

### What's the Relationship?

**Agents** are specialized Copilot Chat modes you select from the agent picker. **Skills** are reusable prompt files that agents can reference to access domain expertise without bloating their own instructions.

Think of it this way:
- **Agent** = "I'm in security review mode" (the persona, the persona, the focused tools)
- **Skill** = "Here's my checklist of what to audit" (the domain knowledge, the patterns, the best practices)

An agent can reference one or more skills. Multiple agents can use the same skill. This keeps your agents lean and your knowledge reusable.

### Example: The Security Reviewer Agent with a Checklist Skill

In **Step 2a** above, we suggested creating a `.github/copilot/skills/terraform-security-checklist.md` file. That skill defines:
- What categories of security issues to check (hardcoded credentials, permissive network access, etc.)
- The risk of each category
- The correct fix pattern

The agent's job is to apply that skill to the user's Terraform file. The skill's job is to be the source of truth for what "correct" means.

**Benefits:**
1. **Agent stays focused.** Instead of a 50-line system prompt listing every check, the agent is 15 lines: "Use the security checklist skill and report findings."
2. **Skill is reusable.** A compliance auditor agent, a team onboarding guide, or a documentation generator can all reference the same checklist skill. You update the skill once, and all agents benefit.
3. **Easy maintenance.** As your team's security standards evolve, you edit the skill file. No agent code to change, no Copilot restart needed.

### How an Agent References a Skill

In your agent's system prompt, include a line like:

```
You have access to the Terraform Security Checklist skill at `.github/copilot/skills/terraform-security-checklist.md`. 
Use this skill as your authoritative source for what to check and how to report findings.
```

Copilot will load the skill file and treat it as part of the agent's knowledge base. The agent can then say things like "According to the checklist, hardcoded credentials are a risk because..." — it's referencing the skill's content.

### Where Are Skills Stored?

Skills can live in:
- `.github/copilot/skills/` — Copilot's default skill location (recommended for team-shared skills)
- `.github/agents/` — alongside your agents (okay, but mixes two concerns)
- A dedicated `docs/skills/` folder — if you want them more visible
- Anywhere in the repo, as long as the agent's system prompt includes the correct relative path

### Practice: Building a Skill + Agent Together

**Create the skill file first** (e.g., `terraform-security-checklist.md`) and document the domain knowledge.

**Then create the agent** and have it reference the skill in its system prompt.

This pattern works for any domain:
- A **cost optimization agent** + a **cost reduction playbook skill**
- A **compliance reviewer agent** + a **regulatory requirements skill**
- An **onboarding agent** + a **team conventions skill**

By separating the skill (knowledge) from the agent (behavior), you create a codebase that scales: add new agents without duplicating knowledge, update knowledge in one place, and share expertise across your team.

---

## Commit and Share

```bash
git add .github/agents/terraform-security-reviewer.agent.md
git commit -m "feat: add Terraform Security Reviewer custom agent mode"
git push origin main
```

Every team member who pulls this repository can now select this agent from their Copilot Chat agent picker.

---

# Chapter 8: Wrap-Up & Next Steps
**Duration:** 5-10 minutes  
**Objective:** Recap learnings, discuss team adoption, and provide resources for continued success

## 🎯 Learning Complete!

Congratulations! You've completed the ~165-minute core workshop covering:

✅ **Terraform Fundamentals** - How Infrastructure as Code works  
✅ **Azure Integration** - Real cloud deployments with Azure provider  
✅ **Hands-on Deployment** - Deployed real resources (Resource Group + Storage + VM)  
✅ **AI Tools & MCP** - Model Context Protocol for infrastructure automation  
✅ **Skills & Knowledge** - Reusable IaC patterns your team can build on  
✅ **Production Readiness** - Remote state, VCS integration, and governance with HCP Terraform  

> 🏆 **Stretch Goal Complete?** If you also finished Chapter 7 (Custom Agents), you've gone above and beyond — you built a specialized Copilot agent tailored to your team's Terraform workflows. That's extra credit worth celebrating.

---

## What You Learned

### Three Pillars of Modern Infrastructure

```
PILLAR 1: TERRAFORM
└─ IaC fundamentals
└─ HCL syntax
└─ State management
└─ Azure resources

PILLAR 2: AI TOOLS
└─ Model Context Protocol (MCP)
└─ Custom agents for specialization
└─ Validation automation
└─ Infrastructure design assistance

PILLAR 3: TEAM PRACTICES
└─ Code review workflows
└─ Governance & compliance
└─ Cost management
└─ Audit logging & accountability
```

---

## Key Takeaways

### Three Critical Mindset Shifts

1. **INFRASTRUCTURE ISN'T SPECIAL**
   - It's code, versioned in git, reviewed like code
   - Yesterday's way: Portal clicks, email procedures
   - Today's way: Code review, CI/CD automation
   
2. **AI MAKES YOU FASTER AND SAFER**
   - Agent assists with design (saves hours)
   - MCP retrieves live Registry and HCP Terraform data (ensures accuracy)
   - Skills encode best practices (prevents mistakes)
   - Result: 10x faster, 1/10th the errors
   
3. **ADOPTION IS A TEAM SPORT**
   - One person doing IaC = cool hobby
   - Team doing IaC standardized = real impact
   - That's why we covered governance, skills, and onboarding

---

## What Happens Tomorrow

### Option A: You Go Back to Portal Clicking
├─ Manual deployments
├─ Hoping you remember the config
├─ No version control
└─ Everyone does it differently

### Option B: You Adopt This (Recommended)
├─ Evaluate Terraform for your current projects
├─ Pick one small project to start (not your most critical one)
├─ Run through the first 4 Chapters again with your team
├─ Get your team on board
├─ Build one skill together
├─ Celebrate your first infrastructure PR
└─ Scale from there

---

## Immediate Next Steps (For the Next Week)

### Day 1-2: Set Up Your Environment
- [ ] Install Terraform CLI on your laptop / Codespaces
- [ ] Create Azure Storage account for remote state
- [ ] Commit .gitignore to your repo
- [ ] Set up Azure service principal (if team)

### Day 3-4: First Real Project
- [ ] Pick a simple resource (storage account, app service)
- [ ] Write Terraform code (use our examples as templates)
- [ ] Run terraform plan locally
- [ ] Deploy by committing and pushing from your learner copy
- [ ] Document your learnings in a skill

### Day 5: Get Team Buy-In
- [ ] Show your deployed infrastructure to your team
- [ ] Demonstrate the terraform plan (show how safe it is)
- [ ] Share the skills you created
- [ ] Invite them to next training session
- [ ] Create Slack channel for infrastructure code discussions

---

## Recommended Reading & Resources

### **Official Documentation** (Bookmark These)
- [Terraform Documentation](https://www.terraform.io/docs) — Everything about Terraform
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) — All Azure resources
- [Azure Architecture Framework](https://learn.microsoft.com/en-us/azure/architecture/) — How to design at scale
- [GitHub Copilot Docs](https://docs.github.com/en/copilot) — Using Copilot effectively

### **Advanced Topics** (For Later)
- **Terraform Modules** — How to reuse infrastructure code (beyond skills)
- **Terraform State Locking** — Prevent concurrent deployments
- **Workspaces & Environments** — Manage dev/staging/prod cleanly
- **Remote Backends** — Store state safely (Terraform Cloud, Azure)
- **Policy as Code** — Enforce infrastructure standards (Sentinel, OPA)

### **Community**
- [Terraform Registry](https://registry.terraform.io/) — Reusable modules
- [HashiCorp Community Forum](https://discuss.hashicorp.com/) — Questions & answers
- [Azure Community](https://techcommunity.microsoft.com/t5/azure/ct-p/Azure) — Azure discussions
- Slack Communities: #terraform, #azure

---

## Real-World Adoption Roadmap

### **Phase 1: Pilot (Weeks 1-3)**
**Goals:**
- Get comfortable with Terraform
- Deploy a non-critical application
- Write first skill together

**Tasks:**
- [ ] Set up Terraform project structure
- [ ] Deploy a test resource to Azure
- [ ] Write one SKILL.md documenting your pattern
- [ ] Get team feedback on approach

**Success Metric:**
- One application fully described in Terraform code

---

### **Phase 2: Team Scaling (Weeks 4-8)**
**Goals:**
- Enable your team to write Terraform
- Create shared skills library
- Set up CI/CD pipeline

**Tasks:**
- [ ] Train team on Terraform fundamentals
- [ ] Create 3-5 skills for your common patterns
- [ ] Set up GitHub Actions or Azure Pipelines
- [ ] Implement code review process for infrastructure

**Success Metric:**
- 70% of team can write Terraform
- 3+ skills documented and in use
- All infrastructure changes through PRs

---

### **Phase 3: Full Adoption (Weeks 9-16)**
**Goals:**
- Make Terraform the standard way to deploy
- Implement governance & cost controls
- Scale to multiple teams

**Tasks:**
- [ ] Migrate existing resources to Terraform (terraform import)
- [ ] Set up cost monitoring & budgets
- [ ] Create compliance checklist for all deployments
- [ ] Implement approval workflows
- [ ] Train new team members on the process

**Success Metric:**
- 100% of infrastructure changes through Terraform
- <10 minutes from code → merged PR → deployed
- Cost visibility across all teams
- Zero security incidents from infrastructure misconfig

---

🎉 You've completed the workshop! Explore the reference folder for advanced topics and bonus deep-dives.

---

## Troubleshooting & Advanced Codespace Tips

### HCP Terraform Credentials in Codespaces

If `terraform init` or `terraform login` doesn't authenticate:

```powershell
# Set the token as an environment variable (most reliable in Codespaces)
$env:TF_TOKEN_app_terraform_io = "your-hcp-token"
```

This environment variable takes precedence over file-based credentials and is the recommended approach for containerized environments like GitHub Codespaces.

### Cleaning Up: Destroying Resources from HCP Terraform VCS Workspace

When your learner-copy repository is connected to HCP Terraform via VCS (Git-based runs), direct `terraform destroy` from the CLI is blocked by default. To clean up resources after the workshop:

**Option 1: Use the HCP UI (Recommended)**
1. Log in to HCP Terraform
2. Navigate to your workspace (Settings)
3. Go to **Destruction and Deletion**
4. Enable destruction and follow the confirmation prompt
5. Resources will be deleted on the next run

**Option 2: Temporarily Switch to CLI Execution Mode**
1. In HCP UI workspace settings, change **Execution Mode** from "Remote" to "Local"
2. Run `terraform destroy` from your learner copy
3. Switch back to "Remote" mode after cleanup

> **Note:** This cleanup process is intentional—it prevents accidental infrastructure destruction. The safety measure ensures deliberate action is required.

### VS Code Editor Shortcuts for Terraform Files in Codespaces

Browser-based Codespaces may intercept keyboard shortcuts like Ctrl+K (comment line). If line commenting doesn't work in `.tf` files:

Add this to your VS Code workspace settings (`.vscode/settings.json` in the repo root):

```json
{
  "[terraform]": {
    "editor.comments.lineComment": "#"
  }
}
```

Then use Ctrl+/ to toggle line comments. Alternatively:
- Right-click and select "Toggle Line Comment"
- Use the keyboard shortcut shown in the Command Palette (`Ctrl+Shift+P` → "Toggle Line Comment")

### Azure VM SKU Gotchas

When deploying Windows VMs, always specify SKUs carefully:

| SKU Pattern | Processor | Windows Support | Example |
|-------------|-----------|-----------------|---------|
| No suffix (e.g., `B2s`) | Intel or AMD | ✅ | Older generation |
| `_v2` suffix (e.g., `B2s_v2`) | Intel | ✅ | Current generation, recommended |
| `a` suffix (e.g., `B2sa`) | AMD | ⚠️ Different licensing | Avoid for workshops |
| `p` suffix (e.g., `B2ps`) | **Arm** | ❌ **Incompatible** | **Do NOT use** |

**For this workshop:** Use `Standard_D2_v4` (Intel, v4 generation).

### Storage Account Access Key Configuration

The Azure Verified Module (AVM) for storage defaults to `shared_access_key_enabled = false` for security. However, if your Terraform code needs to manage data plane resources (blob containers, queues, tables), you must explicitly enable:

```hcl
module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  shared_access_key_enabled = true  # Required for data plane management
  # ... other config
}
```

Without this, Terraform cannot authenticate to manage nested resources inside the storage account.

---



During the development of this manual, the following content was reviewed for attendee vs. facilitator audience:

1. **Agenda Preview (Chapter 1):** Included — attendees benefit from understanding the full workshop flow and timing
2. **Timing Breakdowns:** Included in chapter headers — helps attendees self-pace
3. **Quick Readiness Checks & Verification Checklists:** Included — essential for attendees to confirm progress
4. **Companion Files References:** Included — guides attendees to reference materials and resources
5. **Transition statements:** Edited slightly to be attendee-facing; removed speaker-only guidance
6. **Learning Outcomes:** Included with checkboxes — essential for attendee learning goals
7. **"Why This Chapter Matters" sections:** Included — provides context for attendee learning
8. **Chapter introductions:** Retained and edited for attendee clarity where applicable
