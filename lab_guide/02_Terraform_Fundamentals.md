# Chapter 2: IaC & Terraform Essentials (Compressed)
**Duration:** 5 minutes  
**Objective:** Explain Infrastructure as Code concept and Terraform workflow (for zero experience attendees)

---

## 📍 Learning Outcomes

By the end of this Chapter, participants will:
- [ ] Understand what Infrastructure as Code means
- [ ] Know Terraform's three-step workflow (init, plan, apply)
- [ ] Recognize the key components they'll use today

---

## ⏱️ Timing Breakdown
- **What is IaC?:** 2 min (with analogy)
- **Terraform workflow:** 2 min (visual diagram)
- **Key terms:** 1 min (three components only)

## Workshop Deployment Rule

For this workshop's core path, deployment is triggered by pushing to `main` in each learner copy. `terraform apply` remains a core Terraform concept, but attendees do not run local apply as the primary deployment path in the lab.

---

## 🎤 Speaker Notes

### **What is Infrastructure as Code? (2 min)**

**Hook:**
```
"Infrastructure as Code means one thing: write code that describes your 
cloud infrastructure. Deploy it. Change it. Delete it. All in code.

Think of it like this:
  • Without IaC: Click 50 things in the Azure Portal
  • With IaC: Run three commands. Done.
  
And here's the kicker: when your colleague asks 'how did you set this up?'
Instead of 'um, I clicked things', you say 'here's the code'."
```

**Two-minute explanation:**
- **Traditional:** You manually click Azure Portal → create resources. Hard to repeat. Hard to change. No version history.
- **IaC:** You write code (Terraform) → describe resources → deploy → version in Git

| Aspect | Portal Clicks | Terraform |
|--------|--------------|-----------|
| **Setup time** | 30 minutes of clicking | 5 minutes of typing |
| **Documentation** | Hope someone remembers | Code = documentation |
| **Version control** | None | Full Git history |
| **Repeatability** | Probably made a mistake | Exact same every time |
| **Scale** | 10 environments = 10x clicks | 10 environments = 10x code (with variables) |

**Say:**
> "We're using Terraform. One of its superpowers is that it works with any cloud (Azure, AWS, GCP). We're using it with Azure today."

### **Terraform Workflow: Init → Plan → Apply (2 min)**

**Show this diagram:**

```
┌─────────────────────────────────────────────────────┐
│  Your Terraform Code (main.tf)                      │
│  "I want an Azure Storage Account with these props" │
└────────────────┬────────────────────────────────────┘
                 │
        ┌────────▼──────────┐
        │  terraform init   │
        │  (Setup)          │
        └────────┬──────────┘
                 │
        ┌────────▼──────────┐
        │ terraform plan    │
        │ (What will change?)
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

### **Three Key Components You'll See (1 min)**

Don't go deep. Just point to these three things attendees will see in the repo's actual files:

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

**Say:**
> "That's all you need to know. We'll see these in the next Chapter when we deploy something real. Notice the commented-out blocks in `main.tf` — those are your exercises. You'll uncomment them one at a time."

---

## 🎯 Key Takeaway

**Compressed into one sentence:**
> "Terraform is code that describes the cloud infrastructure you want. You write it, you review it, you deploy it, you version control it. No portal clicking. No manual mistakes."

> 📦 **Where does Terraform state live?**
> 
> In this workshop, state is stored remotely in HCP Terraform — not on your local machine. The `terraform.tf` file in the repo root configures this with a `cloud {}` block pointing to the pre-configured HCP workspace. Remote state means:
> 
> - No `terraform.tfstate` file in your repo (it's stored securely in HCP)
> - Multiple team members can run plans without state conflicts
> - State history and locking are handled automatically
> 
> You can view the current state in the HCP Terraform UI under your workspace's **States** tab.

---

## 🏁 Transition to Chapter 3

**Closing statement:**

```
"Now you know what IaC is and how Terraform works. 

Next, we're writing your first real Terraform resource and deploying 
a storage account to Azure. You'll see how HCL code turns into real 
cloud infrastructure—live, in your account.

Let's do it."
```

> 📚 **Reference:** Azure authentication, Service Principals, environment variables, and CI/CD credential patterns are available as a bonus deep-dive in [reference/bonus-credentials-security.md](./reference/bonus-credentials-security.md).

---

## ❓ Likely Q&A

**Q: "Is Terraform the only IaC tool?"**  
A: "No. There's also Pulumi, Bicep or ARM templates, CloudFormation. But Terraform is cloud-agnostic and works everywhere. That's why we're using it."

**Q: "What's the difference between Terraform and Azure Resource Manager?"**  
A: "Good question. ARM is Azure-only. Terraform works on Azure, AWS, GCP, etc. Terraform also has better syntax (HCL) than ARM's JSON."

**Q: "Can I use Terraform for Kubernetes?"**  
A: "Yes, but that's advanced. Today we're focusing on cloud infrastructure. Kubernetes comes later."

**Q: "What about security? Is my code secure?"**  
A: "Great question. We'll cover that in the next Chapter when we set up HCP Terraform and remote state."

---

## 💡 Pro Tips for Delivery

1. **Use analogies.** "Terraform is like GitOps for infrastructure."
2. **Don't memorize HCL syntax.** Say "Don't worry, you don't need to remember this."
3. **Keep moving.** 5 minutes is tight. If someone asks deep questions, defer to break.
4. **Emphasize the workflow.** Init → Plan → Apply is the ONLY thing they need to remember.

**Talking points:**
- "IaC lets you version infrastructure like code—with git history."
- "You can review infrastructure changes before deployment by checking the plan output and HCP run details."
- "You can deploy to test, stage, prod with the exact same code."
- "If disaster strikes, you can redeploy everything in minutes."

---

**Next:** [Chapter 3: Hands-On First Resource](./03_Hands_On_First_Resource.md)
