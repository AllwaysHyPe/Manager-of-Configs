> **Bonus / Deep-Dive Content:** This is supplementary material. Core path attendees can return here after the workshop.

---
# Chapter 10 (Bonus Deep Dive): Scaling IaC Across Your Organization
**Duration:** 20-25 minutes  
**Objective:** Learn patterns for multi-environment deployments, cost governance, and team adoption

> Optional chapter: This Chapter is outside the core 3-hour workshop path.

---

## 📍 Learning Outcomes

By the end of this Chapter, participants will:
- [ ] Understand multi-environment patterns (dev/staging/prod)
- [ ] Implement cost governance with HCP Terraform
- [ ] Set up team-based workflows and approvals
- [ ] Design a scaling blueprint for their org
- [ ] Know the adoption roadmap (week 1-8)

---

## ⏱️ Timing Breakdown
- **Multi-environment patterns:** 4-5 min
- **Cost governance & controls:** 4-5 min
- **Team workflows & approvals:** 4-5 min
- **Adoption roadmap:** 4-5 min
- **Live demo:** 2-3 min

## Companion Files For This Chapter

- Use [ref-repo-template-guide.md](./ref-repo-template-guide.md) as the reference for the adoption model and starter repo structure.
- Show `README.md` and `variables.tf` when discussing how a team starts with dev and expands later.
- Use [ref-resources.md](./ref-resources.md) for the HCP talking points and reusable commands.
- Reference `.github/copilot-instructions.md` to show how team standards live in code.

---

## 🎤 Speaker Notes

### **Part 1: Multi-Environment Patterns (4-5 min)**

**The Problem:**
> "One environment is fine. But real companies have dev, staging, and production. How do you manage 3x the code?"

**The Pattern: Workspaces + Variables**

```hcl
# main.tf - ONE file for all environments
variable "environment" {
  type = string
  # Set to "dev", "staging", or "prod"
}

variable "instance_count" {
  type        = number
  description = "Dev=1, staging=2, prod=5"
}

resource "azurerm_virtual_machine" "app" {
  count             = var.instance_count
  name              = "vm-${var.environment}-${count.index}"
  resource_group_name = data.azurerm_resource_group.rg.name
  # ...
}
```

**How it works:**
1. **Dev:** `terraform-dev.tfvars` → instance_count=1, smaller sizes
2. **Staging:** `terraform-staging.tfvars` → instance_count=2, medium sizes
3. **Prod:** `terraform-prod.tfvars` → instance_count=5, large sizes

**In HCP Terraform:**
```
Organization: my-company
├── Workspace: dev
├── Workspace: staging
└── Workspace: prod
```

Each workspace points to the SAME repo, but uses different .tfvars files.

**Benefit:**
> "One code base. Three deployments. Changes flow from dev→staging→prod via pull requests. No copy-paste."

### **Part 2: Cost Governance (4-5 min)**

**The Problem:**
> "Someone deploys a 32-core VM thinking it costs $10/month. It actually costs $2000/month. Nobody noticed until the bill came."

**Solution: Cost Controls**

**Layer 1: HCP Terraform Cost Estimation**
- Every `terraform plan` shows estimated monthly cost
- Too high? Terraform warns you before you apply

**Layer 2: Sentinel Policies (Hard Block)**
```
Policy: "No VM with >16 cores"
Policy: "No public database instances"
Policy: "Storage must have encryption enabled"
Policy: "All resources must have a 'cost-center' tag"
```

**When developer tries to deploy something that violates policy:**
```
Policy Check: FAILED
Reason: Storage account is public (policy forbids)
Action: Apply blocked. Fix and re-push.
```

**Layer 3: Tags for Cost Allocation**
```hcl
locals {
  common_tags = {
    environment  = var.environment
    cost_center  = var.cost_center  # Required
    owner        = var.owner        # Required
    project      = var.project      # Required
  }
}

resource "azurerm_storage_account" "data" {
  tags = local.common_tags
}
```

Azure uses tags to roll up costs:
- "Cost center ABC spent $5000 this month"
- "Project X spent $12,000"

**Talking point:**
> "Tags aren't optional. Your CFO wants to know who spent what. Policies enforce it."

### **Part 3: Team Workflows & Approvals (4-5 min)**

**The Flow:**

```
Developer:                     Code a new resource
    ↓
Push to GitHub:                Create pull request
    ↓
HCP Terraform Auto-Run:        Runs terraform plan, shows outputs
    ↓
Peer Review:                   Team reviews code + plan
    ↓
Security/Cost Review:          Policies check + cost estimation
    ↓
Approval:                      Lead approves OR requests changes
    ↓
Merge:                         PR merges to main
    ↓
HCP Auto-Apply:                Applies to production
    ↓
Done:                          Infrastructure deployed safely
```

**GitHub Integration Config:**

In `.github/workflows/terraform.yml`:

```yaml
name: Terraform Plan & Apply

on: [push, pull_request]

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
        with:
          cloud_token: ${{ secrets.TF_API_TOKEN }}
      - run: terraform plan -out=tfplan
      - uses: hashicorp/terraform-github-actions@main
        with:
          tf_actions_version: latest
          tf_actions_working_dir: .
          tf_actions_comment: true

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - run: terraform apply tfplan
```

**What this does:**
- "Every push triggers a plan. Results show in the PR."
- "Merge to main? It auto-applies. No manual 'terraform apply' needed."

**Roles & Permissions:**

```
Developer:  Can write Terraform code, cannot approve
Reviewer:   Can review code, must approve before apply
Security:   Policies auto-check, can override if needed
Lead:       Final authority on applies
```

### **Part 4: 8-Week Adoption Roadmap (4-5 min)**

**How do you actually roll this out to your org?**

**Week 1-2: Foundation**
- [ ] Set up HCP Terraform organization
- [ ] Create GitHub repo with Terraform structure
- [ ] Migrate one team's infrastructure to Terraform
- [ ] Set up basic CI/CD (GitHub Actions)
- **Time commitment:** 5 hours

**Week 3-4: Governance**
- [ ] Create Sentinel policies (cost, security, tagging)
- [ ] Document your Terraform standards
- [ ] Train first team on the workflow
- [ ] Do 5-10 test deployments
- **Time commitment:** 8 hours

**Week 5-6: Skills & Automation**
- [ ] Create 2-3 reusable skills (multi-tier app, security baseline)
- [ ] Build custom agents for your company
- [ ] Automate cost reports (monthly dashboard)
- [ ] Integrate with Slack notifications
- **Time commitment:** 10 hours

**Week 7-8: Scale**
- [ ] Migrate all infrastructure teams to Terraform
- [ ] Set up cross-team reviews & approvals
- [ ] Monthly audit of costs
- [ ] Celebrate wins and document lessons
- **Time commitment:** 15 hours

**Total effort:** ~40 hours (1 person, 2 months) to go org-wide.

**Return on investment:**
- Deployment speed: 10x faster
- Disaster recovery: minutes instead of days
- Cost visibility: per team/project
- Compliance: auto-enforced policies

---

## 💰 Cost Governance Live Demo (2-3 min)**

**Show in HCP UI:**

1. Go to **Workspaces** → your workspace
2. Click **Costs** tab
3. Show "Estimated monthly: $XXX"

**Then under Policies:**
1. Click **Policies**
2. Show a sample policy (or mock one)
3. "This policy blocks public databases. Developers can't bypass it."

---

## 📊 Repository Template Sneak Peek (1-2 min)**

**What they'll get after workshop:**

A GitHub repo they can CLONE with:
- ✅ Multi-environment Terraform structure
- ✅ HCP Terraform config (ready to connect)
- ✅ GitHub Actions CI/CD (ready to deploy)
- ✅ Sentinel policies (security + cost)
- ✅ Tags enforcement
- ✅ Cost reporting script
- ✅ Team workflow documentation

**Say:**
> "This is your starting point. Clone it, add your resources, push, and watch Terraform run automatically. No setup friction."

---

## 🎯 Key Takeaway

**One paragraph:**
> "Terraform at scale means: one codebase / multiple environments, policies that enforce governance, teams that review and approve, and cost visibility by project. This is how enterprises do IaC."

---

## 🏁 Transition to Chapter 11

**Closing statement:**

```
"You now have everything:
  ✅ Hands-on Terraform skills
  ✅ Copilot + MCP for speed
  ✅ Custom agents & skills
  ✅ HCP for governance & state
  ✅ Patterns for multi-environment
  ✅ Cost controls

Last Chapter: we wrap up, show you the template you can clone,
and send you off to ship infrastructure at your company.

Let's finish strong."
```

---

## ❓ Likely Q&A

**Q: "What if two teams push at the same time?"**  
A: "HCP locks state during apply. Second push waits. No conflicts. That's why remote state is important."

**Q: "How do we handle rollbacks?"**  
A: "Revert the Git commit. Push. Terraform reapplies the previous state. Done."

**Q: "What's the security risk of shared access?"**  
A: "That's why we have roles (developer, reviewer, lead). Not everyone can approve applies. Also, all changes are logged."

**Q: "Can we use this with existing infrastructure?"**  
A: "Yes. `terraform import` brings existing resources into your state. It's a bit tedious but doable."

---

## 💡 Pro Tips for Delivery

1. **Show the cost tab.** Real numbers. It resonates.
2. **Mention Slack integration.** "When production deploys, Slack posts the summary." Teams love this.
3. **Rollback example:** "Forgot a firewall rule? Undo Git commit, redeploy. 2 minutes."
4. **Template excitement:** "You're leaving with a cloneable repo. No setup friction."

---

**Next:** [bonus-governance-and-team-workflows.md](./bonus-governance-and-team-workflows.md)

