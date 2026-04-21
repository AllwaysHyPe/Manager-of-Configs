# Chapter 3: Credentials & Security
**Duration:** 15-20 minutes  
**Objective:** Safely authenticate with Azure in Terraform without hardcoding secrets

---

## � Your Attendee Number

> **Before you start:** You've been assigned an attendee number (e.g., `01`, `02`, `03`…). Use it throughout this workshop to keep your Azure resources uniquely named and avoid collisions with other attendees on the same Entra ID tenant.
>
> Wherever you see `{N}` in this chapter, substitute your attendee number — e.g., `terraform-sp-01`, `my-rg-03`.

---

## �📍 Learning Outcomes

By the end of this Chapter, participants will be able to:
- [ ] Understand Azure authentication options for Terraform
- [ ] Configure Terraform to use Azure CLI credentials
- [ ] Use Service Principals for automated deployments
- [ ] Manage secrets safely (environment variables, .gitignore)
- [ ] Recognize common authentication mistakes

---

## ⏱️ Timing Breakdown
- **Authentication options overview:** 3-4 min
- **Azure CLI credentials (simplest):** 3-4 min
- **Service Principals (production):** 4-5 min
- **Security best practices:** 3-4 min
- **Q&A:** 1-2 min

---

## 🎤 Speaker Notes & Slides

## Workshop Scope Note

In the core workshop path, attendees do not manage Azure RBAC/scoping. The preconfigured HCP Terraform workflow handles deployment. The Azure CLI auth section below is the primary hands-on path for local verification. Service Principal, environment variable setup, and CI/CD credential workflows are moved to a Reference section at the end of this chapter for post-workshop learning.

### **Opening Hook (1 min)**

```
"Here's the most common Terraform security mistake:

Someone writes:
  provider "azurerm" {
    client_id       = "xxx"
    client_secret   = "xxx"
    subscription_id = "xxx"
    tenant_id       = "xxx"
  }

Then they commit it to GitHub. In 3 minutes, attackers scan public 
repos for secrets and compromise the account.

We're going to learn the RIGHT way to handle credentials."
```

---

### **Part 1: Authentication Options (3-4 min)**

**Four ways to authenticate with Azure in Terraform:**

| Method | How It Works | Best For | Setup Time |
|--------|-------------|----------|------------|
| **1. Azure CLI** | Uses your `az login` session | Local development | < 1 min |
| **2. Environment Variables** | Pass credentials via ENV vars | Scripting, CI/CD | 2-5 min |
| **3. Service Principal** | Dedicated "bot" account for automation | Production, teams | 10-15 min |
| **4. Managed Identity** | Azure-native identity (VMs, containers) | Azure-hosted code | 5-10 min |

**Quick comparison matrix:**

```
Method          │ Secure? │ Easy? │ Scoped? │ For Teams?
────────────────┼─────────┼───────┼─────────┼──────────
Azure CLI       │ ⭐⭐   │ ⭐⭐⭐ │ ❌      │ ❌
Env Variables   │ ⭐⭐⭐ │ ⭐⭐   │ ⭐⭐⭐ │ ⭐
Service Prin.   │ ⭐⭐⭐ │ ⭐⭐   │ ⭐⭐⭐ │ ⭐⭐⭐
Managed ID      │ ⭐⭐⭐ │ ⭐⭐⭐ │ ⭐⭐⭐ │ ⭐⭐
```

**Talking points:**
- "For TODAY'S hands-on: We're using Azure CLI because it's instant."
- "For PRODUCTION: You'll use Service Principals or Managed Identities."
- "NEVER: hardcode secrets in Terraform code."

---

### **Part 2: Azure CLI Authentication (3-4 min)**

**The easiest route for local development:**

**Step 1: Login**
```bash
az login

# Interactive browser opens, you sign in, and...
```

**Step 2: Terraform detects your session**
```bash
# No configuration needed! Terraform automatically uses your Azure CLI credentials.
# This only works because we set ARM_USE_CLI=true (or Terraform does it by default in newer versions).
```

**Step 3: Verify it works**
```bash
az account show
# Output shows:
# {
#   "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   "name": "My Subscription",
#   ...
# }
```

**Terraform configuration (minimal):**
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.66"
    }
  }
}

provider "azurerm" {
  features {}
  
  # That's it! Terraform uses az login credentials automatically.
  # (Technically, you can set subscription_id if you want to be explicit)
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

**Magic happens here:**
```
Terraform looks for credentials in this order:

1. Environment variables (ARM_CLIENT_ID, ARM_CLIENT_SECRET, etc.)
   ↓
2. Azure CLI cache (~/.azure/)
   ↓
3. Managed Identity (if running on Azure)
   ↓
4. (falls back to interactive login if none found)

So if you've done 'az login', Terraform finds your session. Done!
```

**Live demo:**
```bash
# Show participants the Azure CLI cache location
ls ~/.azure/  # macOS/Linux
dir %USERPROFILE%\.azure\  # Windows

# Show current session
az account show

# Now initialize Terraform (it will use these credentials)
terraform init
terraform plan

# Terraform successfully authenticated! No secrets in code.
```

**Talking point:**
> "This is why prerequisites matter. Once you've run `az login`, Terraform automatically uses those credentials. No configuration, no secrets. It's beautiful."

---

### **Part 3: Security Best Practices (3-4 min) - Core Path**

**CRITICAL: .gitignore settings**

```bash
# Create a .gitignore in your Terraform project
cat > .gitignore << 'EOF'
# Terraform state files (contain sensitive data)
*.tfstate
*.tfstate.*
terraform.tfstate

# Local .terraform directory
.terraform/

# Terraform override files (often contain secrets)
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Variable files (might contain hardcoded values)
# *.tfvars  ← Uncomment if using tfvars (use terraform.tfvars.example instead)
# *.tfvars.json

# IDE directories
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
EOF
```

**Why?**
- **Terraform state = secrets**. It contains passwords, connection strings, private keys.
- **.terraform/ = huge**. No need to commit plugin cache.
- **Variable files = hardcoded values**. Use examples and override at deployment time.  

---

## 🏁 Live Demo: Setting Up Credentials (5 min real-time)

**Instructor walkthrough:**

```bash
# 1. Show current Azure session
az account show

# 2. Use your pre-assigned resource group (replace {N} with your attendee number)
#    Everyone shares the same Entra ID — unique names prevent collisions
RG_NAME="workshop-rg-{N}"

# 3. Initialize a minimal Terraform project
mkdir test-terraform-{N} && cd test-terraform-{N}

# 4. Create main.tf
cat > main.tf << 'EOF'
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.66"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Your sub ID
}

resource "azurerm_storage_account" "demo" {
  name                     = "demostg{N}${formatdate("YYYYMMDDhhmm", timestamp())}"
  resource_group_name      = "workshop-rg-{N}"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

output "storage_account_id" {
  value = azurerm_storage_account.demo.id
}
EOF

# 5. Initialize Terraform
terraform init

# 6. See the plan (no credentials needed - it uses az login)
terraform plan

# 7. Cleanup
cd ..
rm -rf test-terraform-{N}
```

---

## 🎯 Quick Reference Checklist

Before moving to Chapter 4, confirm participants:

- [ ] Understand their attendee number and why it's needed (shared Entra ID)
- [ ] Understand why hardcoding secrets is bad
- [ ] Know `az login` automatically gives Terraform credentials
- [ ] Have `.gitignore` configured to exclude state files
- [ ] Understand the principle of least privilege

---
> 📚 **Reference:** Extended material on Service Principals and CI/CD credential patterns is in [ref-credentials-security.md](./ref-credentials-security.md)

## ❓ Likely Q&A

**Q: "Why can't I just use my Azure credentials directly?"**  
A: "You can for local development (via Azure CLI). But for teams and CI/CD, you want a Service Principal—a dedicated 'bot account' that can be rotated independently."

**Q: "What happens if I accidentally commit tfstate to git?"**  
A: "Someone with git history access can extract secrets. Best practice: immediately rotate all secrets and remove the commit from history (git-filter-repo)."

**Q: "Can I use multi-factor authentication with Terraform?"**  
A: "Not directly. That's why you use Service Principals for automation—they don't require MFA. For local development, use Azure CLI (which supports MFA)."

**Q: "How do I handle multiple Azure subscriptions?"**  
A: "Set the subscription_id in your provider block or via ARM_SUBSCRIPTION_ID. Or create multiple provider blocks with aliases: `provider "azurerm" { alias = "prod" }`."

**Q: "Is it safe to store secrets in terraform.tfvars?"**  
A: "No. Git will track it. If you need different values per environment, use `-var` flag or environment variables (ARM_*) instead."

---

## 💡 Pro Tips for Delivery

1. **Emphasize security.** "This is the #1 mistake teams make."
2. **Show the .gitignore demo.** Actually add it to the example project.
3. **Make Azure CLI "magic" relatable.** "Terraform piggybacks on your session."
4. **Demystify Service Principals.** "It's just a 'bot account' with credentials."
5. **Give them a checklist.** Print the "DO's and DON'Ts" slide for reference.

---

**Next:** [Chapter 4: Hands-On - Deploy Your First Resource](./04_Hands_On_First_Resource.md)
