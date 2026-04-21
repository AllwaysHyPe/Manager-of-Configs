> **Bonus / Deep-Dive Content:** This is supplementary material. Core path attendees can return here after the workshop.

---
# Chapter 11 (Bonus Deep Dive): Governance & Team Workflows
**Duration:** 15-20 minutes  
**Objective:** Scale Terraform & AI tools across teams with governance, approval workflows, and shared standards

> Optional chapter: This Chapter is outside the core 3-hour workshop path.

---

## 📍 Learning Outcomes

By the end of this Chapter, participants will understand:
- [ ] Remote state management for teams
- [ ] Code review and approval workflows for infrastructure
- [ ] Enforcing standards through agents and skills
- [ ] Cost governance and budgeting
- [ ] Audit logging and compliance
- [ ] Onboarding team members safely

---

## ⏱️ Timing Breakdown
- **Remote state & team setup:** 3-4 min
- **Code review workflows:** 3-4 min
- **Cost governance:** 2-3 min
- **Compliance & auditing:** 2-3 min
- **Team onboarding:** 2-3 min
- **Q&A:** 1-2 min

## Companion Files For This Chapter

- Use [ref-repo-template-guide.md](./ref-repo-template-guide.md) to connect governance choices back to the cloneable repo design.
- Show `.github/copilot-instructions.md` and the sample skills to demonstrate how team standards live next to code.
- Use [ref-resources.md](./ref-resources.md) for commands and talking points when you need a shorter governance demo.

---

## 🎤 Speaker Notes

### **Opening (1 min)**

```
"Great infrastructure code is useless if your team can't collaborate on it.

Right now, you've deployed infrastructure successfully. But:
  ❓ How do we prevent bad actors from running `terraform destroy`?
  ❓ How do we enforce team standards across 10 projects?
  ❓ How do we roll out agent/skill knowledge?
  ❓ How do we audit who changed what?
  ❓ How do we manage costs at scale?

That's governance. Let's tackle it."
```

---

## **Part 1: Remote State Management (3-4 min)**

### **Problem: Local State Doesn't Scale**

```
Bad ❌
├─ .tfstate file on laptop
├─ "Who has the latest state?"
├─ "My database crashed, rebuild from scratch"
└─ No backup, no versioning, no audit trail

Good ✅
├─ State in Azure Storage
├─ Encrypted, backed up, versioned
├─ Audit log of all changes
├─ State locking (prevents conflicts)
└─ Team can collaborate safely
```

### **Set Up Remote State (Code Example)**

```hcl
# In your project: backend.tf

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateaccount"  # Must be globally unique
    container_name       = "tfstate"
    key                  = "production.tfstate"  # Per-environment
  }
}
```

**Setup Steps:**

```bash
# 1. Create resource group for state
az group create --name rg-terraform-state --location eastus

# 2. Create storage account
az storage account create \
  --name tfstateaccount \
  --resource-group rg-terraform-state \
  --sku Standard_LRS \
  --https-only

# 3. Create container
az storage container create \
  --account-name tfstateaccount \
  --name tfstate

# 4. Enable versioning
az storage account blob-service-properties update \
  --account-name tfstateaccount \
  --enable-versioning

# 5. Enable encryption (default, but be explicit)
# Azure does this automatically for new accounts

# 6. Lock down access
# Only allow Terraform service principal to access
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee {service-principal-id} \
  --scope /subscriptions/{sub-id}/resourceGroups/rg-terraform-state/providers/Microsoft.Storage/storageAccounts/tfstateaccount
```

**Result:**
- State file encrypted at rest
- Versioned (history of all changes)
- Backed up automatically
- Access controlled (only approved principals)
- Audit trail (who changed what, when)

---

## **Part 2: Code Review & Approval Workflows (3-4 min)**

### **The Gold Standard: GitHub Flow + Terraform**

```
┌─────────────────────────────────────────────────┐
│  Developer: "I need to update networking"       │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  1. CREATE BRANCH: git checkout -b feat/network │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  2. CODE: Edit Terraform files                  │
│     - Add security rules                        │
│     - Update CIDR blocks                        │
│     - Add documentation                         │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  3. COMMIT: git commit -m "feat: Add NSG rules" │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  4. PUSH: git push origin feat/network          │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  5. CREATE PR on GitHub                        │
│     - Automated checks run:                     │
│       ✓ terraform validate                     │
│       ✓ terraform plan (show changes)          │
│       ✓ Security scan                          │
│       ✓ Cost estimation                        │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  6. CODE REVIEW: Team reviews PR               │
│     - Check terraform plan output              │
│     - Check security implications              │
│     - Check cost impact                        │
│     - Approve or request changes               │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  7. MERGE: Approved PR merged to main           │
│     Auto-trigger: terraform apply              │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│  8. DEPLOY: Resources created in Azure          │
│     - Logged in audit trail                     │
│     - Prometheus metrics updated                │
└─────────────────────────────────────────────────┘
```

### **Example GitHub Actions Workflow**

```yaml
name: Terraform Plan & Apply

on:
  push:
    branches: [main]
    paths: ['terraform/**']
  pull_request:
    branches: [main]
    paths: ['terraform/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    env:
      ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
    
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      
      # Step 1: Validate syntax
      - name: Terraform Validate
        run: terraform validate -no-color
      
      # Step 2: Format check
      - name: Terraform Format
        run: terraform fmt -check
      
      # Step 3: Plan (on PRs)
      - name: Terraform Plan (PR)
        if: github.event_name == 'pull_request'
        run: |
          terraform init
          terraform plan -no-color -out=tfplan
      
      # Step 4: Upload plan artifact
      - name: Upload Plan
        if: github.event_name == 'pull_request'
        uses: actions/upload-artifact@v3
        with:
          name: tfplan
          path: tfplan
      
      # Step 5: Comment plan on PR
      - name: Comment plan on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('tfplan', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `\`\`\`\nTerraform Plan:\n${plan}\n\`\`\``
            });
      
      # Step 6: Apply (only on main branch)
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: |
          terraform init
          terraform apply -auto-approve -no-color
      
      # Step 7: Slack notification
      - name: Notify Slack
        if: always()
        run: |
          # Send deployment status to Slack channel
          echo "Deployment status: ${{ job.status }}"
```

**Key Insights:**
- ✅ All changes in git (audit trail)
- ✅ Automated validation (catch errors early)
- ✅ Human review (override gate)
- ✅ Automated deployment (after approval)
- ✅ Notification trail (everyone knows what happened)

---

## **Part 3: Cost Governance (2-3 min)**

### **The Cost Problem**

```
Without governance:
  ❌ "Who provisioned a Premium SQL Database in dev?"
  ❌ "$5,000/month bill; we budgeted $2,000"
  ❌ "5 unused storage accounts sitting around"
  
With governance:
  ✅ "I estimated $200/month for this PR (see comment)"
  ✅ Agent warns: "Premium tier unusual for dev"
  ✅ Cost scan finds: "3 unused resources, $500/month"
```

### **Cost Controls in Terraform**

```hcl
# 1. Enforce limits per resource

variable "max_app_service_sku" {
  type        = string
  description = "Max App Service SKU in dev (prevent expensive mistakes)"
  default     = "B2"  # Dev not allowed > B2
  
  validation {
    condition     = contains(["B1", "B2", "S1"], var.app_service_sku)
    error_message = "App Service SKU must be B1, B2, or S1 in dev."
  }
}

# 2. Tag all resources for cost allocation

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  
  tags = {
    CostCenter = var.cost_center  # required
    Environment = var.environment  # required
    Owner = var.owner              # required
    Project = var.project          # required
  }
}

# 3. Output cost estimate

output "estimated_monthly_cost" {
  value       = "App Service: $50 + DB: $200 + Storage: $30 = ~$280/month"
  description = "Remember: manually verify in Azure Cost Calculator"
}
```

### **Automated Cost Reports**

Your CI/CD can generate cost estimates:

```bash
# terraform-cost-report.sh
terraform plan -json | tfcost estimate

# Output:
# Resource Group: rg-document-processing-dev
# ┌─────────────────────────────────────────┐
# │ Service          │ SKU       │ Cost     │
# ├──────────────────┼───────────┼──────────┤
# │ App Service      │ B1        │ $15/mo   │
# │ SQL Database     │ Standard  │ $200/mo  │
# │ Storage Account  │ Hot       │ $30/mo   │
# │ Redis           │ C0        │ $16/mo   │
# │ Key Vault        │ Standard  │ $1/mo    │
# └─────────────────────────────────────────┘
# TOTAL: $262/month
```

---

## **Part 4: Compliance & Auditing (2-3 min)**

### **What You Need to Audit**

```
Who?     - User/Service Principal
What?    - What resource changed
When?    - Timestamp
Where?   - Which Azure subscription
Why?     - PR/issue/ticket
How?     - terraform apply / CLI / Portal

All of this gets logged automatically when using:
  ✅ Terraform in CI/CD (git audit trail)
  ✅ Azure Resource Groups (activity log)
  ✅ Log Analytics (query anything)
```

### **Example: Compliance Checklist**

```yaml
# compliance.yaml - Required for all deployments

compliance:
  encryption:
    at_rest: true      # All storage must be encrypted
    in_transit: true   # TLS 1.2+ required
  
  network_isolation:
    private_endpoints: true  # No public IPs unless approved
    nsg_rules: true          # All traffic whitelisted
  
  identity:
    managed_identities: true # Use Managed ID, not secrets
    rbac_least_privilege: true
  
  audit_logging:
    enabled: true
    retention_days: 365
  
  backup:
    enabled: true
    frequency: daily
    retention_days: 30
  
  cost:
    monthly_budget: 5000  # Alert if exceeded
```

**The Agent Enforces This:**

```
User: "Create a storage account"

Agent: "I'll create it with compliance checklist:
✅ Encryption at rest: enabled
✅ Encryption in transit: TLS required
✅ Network: private endpoint only
✅ Audit logging: 365-day retention
✅ Backup: daily, 30-day retention

Any issues?"

If user tries to create unencrypted storage:
❌ Agent blocks: "Unencrypted storage violates compliance policy.
   Use: account_kind = 'StorageV2', encrypted = true"
```

---

## **Part 5: Team Onboarding (2-3 min)**

### **Day 1: New Engineer Joins**

```markdown
# Welcome to the Infrastructure Team!

## Your First Day:

1. **Clone the repo**
   git clone https://github.com/ourcompany/infrastructure.git
   cd infrastructure

2. **Read the README**
   - Terraform structure overview
   - How we organize environments
   - Approval workflow

3. **Read the Skills**
   - skills/deploy-multi-tier-app/SKILL.md
   - skills/network-security-baseline/SKILL.md
   (This is how we build things)

4. **Meet the Agent**
   @TerraformArchitect
   "Hello TerraformArchitect, here's what I need to learn"
   (The agent is your mentor)

5. **First Task: Review a PR**
   - Opens PR: "Add Redis to document processing app"
   - Run: terraform plan
   - Read the output
   - Leave a code review comment
   - Someone will mentor you on feedback

6. **First Task: Small Change**
   - Branch: git checkout -b docs/update-readme
   - Update documentation
   - Create PR
   - Get reviewed and merged
   - "You've done your first infrastructure change!"

## Key Resources:
- [Terraform Docs](https://www.terraform.io/docs)
- [Azure Architecture Framework](https://learn.microsoft.com/en-us/azure/architecture/)
- [ref-resources.md](./ref-resources.md)
- [ref-repo-template-guide.md](./ref-repo-template-guide.md)
- `.github/copilot-instructions.md`
- `.github/skills/`
- Slack channel: `#infrastructure-team`
```

---

## 🏁 Transition to Chapter 13

**Closing statement:**

```
"You're now thinking like infrastructure teams with governance.

Not just:
  ❌ "Build it and hope it works"

But:
  ✅ Code review (humans + machines)
  ✅ Automated validation (no bad configs)
  ✅ Cost controls (stay under budget)
  ✅ Compliance enforcement (standards met)
  ✅ Audit trails (who did what, when)
  ✅ Team safeguards (prevent disasters)

This is how mature teams operate.

In the final Chapter, we're going to wrap up and send you off 
with everything you need to own this in your organization."
```

---

## 🎯 Quick Verification Checklist

Before moving to Chapter 13:

- [ ] Understand remote state benefits and setup
- [ ] Know the GitHub flow for infrastructure
- [ ] Can explain cost governance
- [ ] Understand compliance automation
- [ ] Ready to onboard team members

---

## ❓ Likely Q&A

**Q: "What if someone runs terraform destroy without approval?"**  
A: "That's why we use: (1) code review in PRs, (2) Azure RBAC limits who can destroy, (3) state in remote storage (not local laptop), (4) audit logs catch it. Multiple safeguards."

**Q: "How do we prevent skill/agent drift?"**  
A: "Skills are in git. Agents reference .instructions.md in git. Everyone gets the same version. Enforce via code review."

**Q: "Can I test changes without deploying?"**  
A: "Exactly what terraform plan is for. It shows what would change without actually changing it."

---

## 💡 Pro Tips for Delivery

1. **Show the workflow visually.** Branch → PR → Checks → Merge → Deploy. It's compelling.
2. **Make governance sound good, not restrictive.** Frame it as "safeguards" not "rules."
3. **Mention cost wins.** "You can catch a $2,000 mistake in PR review instead of finding it in the bill."
4. **Real example.** Show your actual GitHub workflow/cost report/audit log if available.

---

**Next:** [Chapter 13: Wrap-Up & Next Steps](../08_Wrap_Up.md)

