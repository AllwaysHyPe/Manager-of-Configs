# Reference: Service Principals and Automation Credentials
> This is supplementary material. Core path attendees can return here after the workshop.

---
## 🔗 Reference: Service Principals and Automation Credentials (Post-Workshop)

For the core workshop path, Azure CLI authentication is sufficient. The sections below are preserved as reference material for post-workshop scenarios: team automation, CI/CD pipelines, and manual deployments.

---

### **Reference Part 1: Environment Variables for Automation**

**For scripting and CI/CD scenarios that need more control:**

**Create a Service Principal** (requires Azure admin help)

For production/team scenarios, scope the Service Principal to a resource group (principle of least privilege):

```bash
# Create SP scoped to RESOURCE GROUP (not subscription)
# Use your attendee number to keep the name unique in the shared Entra ID tenant
az ad sp create-for-rbac \
  --name "terraform-sp-{N}" \
  --role Owner \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}

# Output includes:
# {
#   "appId": "xxxxxxxx-xxxx-...",           ← CLIENT_ID
#   "password": "xxxxxxxxxxxxxxxx",         ← CLIENT_SECRET
#   "tenant": "xxxxxxxx-xxxx-...",          ← TENANT_ID
# }
```

**Export credentials as environment variables:**

```bash
# macOS/Linux
export ARM_CLIENT_ID="xxxxxxxx-xxxx-..."
export ARM_CLIENT_SECRET="xxxxxxxxxxxxxxxx"
export ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-..."
export ARM_TENANT_ID="xxxxxxxx-xxxx-..."

# Windows PowerShell
$env:ARM_CLIENT_ID = "xxxxxxxx-xxxx-..."
$env:ARM_CLIENT_SECRET = "xxxxxxxxxxxxxxxx"
$env:ARM_SUBSCRIPTION_ID = "xxxxxxxx-xxxx-..."
$env:ARM_TENANT_ID = "xxxxxxxx-xxxx-..."
```

**Terraform configuration automatically reads these:**

```hcl
provider "azurerm" {
  features {}
  # Terraform automatically reads ARM_* environment variables
}
```

**Why use environment variables instead of hardcoding?**

```
✅ Secrets stay OUT of code
✅ You can swap secrets for different environments
✅ Perfect for CI/CD pipelines (GitHub Actions, Azure Pipelines)
✅ Easier to rotate secrets

# Bad (DO NOT DO):
provider "azurerm" {
  client_id       = "xxx"     ❌ EXPOSED IN GIT
  client_secret   = "yyy"     ❌ LEAKED
}

# Good:
provider "azurerm" {
  features {}
  # Pull from environment variables instead
}
```

**Where to store these variables:**

| Scenario | How to Store |
|----------|-------------|
| **Local laptop** | `~/.bashrc` or `~/.bash_profile` (source it on terminal open) |
| **Team project** | Azure Key Vault (not in git) |
| **CI/CD (GitHub)** | GitHub Actions Secrets |
| **CI/CD (Azure)** | Azure Key Vault + Azure Pipelines |

**Never store in these places:**
```
❌ source code
❌ git history
❌ .tfvars files
❌ Slack, email, Jira (use secrets tools only)
```

---

### **Reference Part 2: Service Principals for Teams**

**Why Service Principals?**

```
Scenario: You have a team of 5 engineers.

Option A: Everyone uses their personal Azure CLI login
  ❌ When Jane leaves, you have to revoke her access everywhere
  ❌ Audit logs say "Jane deployed this" but she was helping John
  ❌ Can't rotate the secret without resetting her password

Option B: Create a Service Principal for the team
  ✅ Team shares one set of credentials (in secure vault)
  ✅ Audit logs say "Terraform Service Principal deployed this"
  ✅ Rotate credentials by re-creating the SP secret
  ✅ Scope it to ONLY what the team needs (least privilege)
```

**Creating a Service Principal:**

```bash
# Step 1: Create the SP
# Append your attendee number — everyone shares the same Entra ID tenant
az ad sp create-for-rbac \
  --name "terraform-workshop-sp-{N}" \
  --role "Contributor" \
  --scopes /subscriptions/{subscription-id}

# Output:
# {
#   "appId": "d1234567-e890-12f4-a456-426614174000",
#   "displayName": "terraform-workshop-sp-{N}",
#   "password": "~Z235Q~1234567890abcdefghijklmnop",
#   "tenant": "a1234567-b890-12c3-d456-789012345678"
# }

# Step 2: Store these securely (Azure Key Vault, GitHub Secrets, etc.)

# Step 3: Use them in Terraform via environment variables
export ARM_CLIENT_ID="d1234567-e890-12f4-a456-426614174000"
export ARM_CLIENT_SECRET="~Z235Q~1234567890abcdefghijklmnop"
export ARM_SUBSCRIPTION_ID="y1234567-z890-12a3-b456-789012345678"
export ARM_TENANT_ID="a1234567-b890-12c3-d456-789012345678"

# Step 4: Run Terraform (reference-only local apply flow)
terraform init
terraform plan
terraform apply
```

**Scoping a Service Principal (BEST PRACTICE):**

```bash
# Instead of "Contributor" (broad), use a custom role or scoped role

# Option A: Scope to a resource group (not the whole subscription)
# Remember to append your attendee number {N}
az ad sp create-for-rbac \
  --name "terraform-rg-deployer-{N}" \
  --role "Contributor" \
  --scopes /subscriptions/{sub-id}/resourceGroups/my-rg-{N}

# Option B: Create a custom role with minimal permissions
# (This is advanced, skip for this workshop, but it's best practice)
```

**Credential Rotation:**

```bash
# Every 90 days (or per your policy), rotate the SP secret

# Step 1: Create a new secret (use your attendee number)
az ad sp credential reset \
  --name terraform-workshop-sp-{N}

# Step 2: Update it in your secrets vault (Key Vault, GitHub Secrets, etc.)

# Step 3: Verify the new credentials work
export ARM_CLIENT_SECRET="new-secret-value"
terraform plan

# Step 4: Remove old secret from Azure
az ad sp credential delete \
  --name terraform-workshop-sp-{N} \
  --key-id {old-key-id}
```

---

### **Reference Part 3: Running in CI/CD Securely**

**Example: GitHub Actions Workflow**

```yaml
# .github/workflows/terraform-deploy.yml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    env:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}          # From GitHub Secrets
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      
      - run: terraform init
      - run: terraform plan -out=tfplan
      - run: terraform apply tfplan
```

**Key rules for secrets in CI/CD:**

✅ Store secrets in GitHub Secrets / Azure Key Vault  
✅ Pass them via environment variables at deployment time  
✅ Never commit them to git  
✅ Use the principle of least privilege (minimal scoping)  
✅ Rotate regularly (monthly or quarterly)  

❌ Never hardcode in code  
❌ Never email or Slack them  
❌ Never use personal credentials for automation  

---
