> **Bonus / Deep-Dive Content:** This is supplementary material. Core path attendees can return here after the workshop.

---
# Bonus Chapter: Advanced Capstone - AI-Assisted Infrastructure Design
**Duration:** Optional 25-30 minutes  
**Objective:** Optional synthesis lab to combine agent assistance, MCP validation, and skill guidance in a single scenario

> Optional chapter: This is intentionally outside the core 3-hour workshop path.

---

## 📍 Learning Outcomes

By the end of this Chapter, participants will be able to:
- [ ] Collaborate with an AI agent on infrastructure design
- [ ] Use Terraform MCP for validation and feedback
- [ ] Apply skills to ensure compliance and best practices
- [ ] Design multi-environment deployments
- [ ] Validate and deploy infrastructure safely
- [ ] Understand human-in-the-loop IaC workflows

---

## ⏱️ Timing Breakdown
- **Capstone scenario introduction:** 2-3 min
- **Design phase with agent assistance:** 6-8 min
- **Generate Terraform code:** 3-4 min
- **Validation with MCP:** 4-5 min
- **Apply and verify:** 4-5 min
- **Review and improvements:** 3-4 min
- **Q&A:** 1-2 min

---

## 🎤 Speaker Notes & Slides

### **Opening Hook (2 min)**

```
"We've covered:
  ✓ Terraform fundamentals
  ✓ Security and credentials
  ✓ Real Azure deployments
  ✓ AI tools and MCP servers
  ✓ Custom agents
  ✓ Reusable skills

Now comes the capstone. Everything together.

Scenario: Your company wants to launch a new SaaS product.
You need to design the infrastructure, deploy it to dev/staging/prod,
and make sure it meets security and cost requirements.

Normally, this takes a team a week. With AI-assisted design, we're
doing it in 30 minutes.

Let's go!"
```

---

## **Part 1: Capstone Scenario (2-3 min)**

⚠️ **Setup Note:** Each participant has been assigned a resource group (provided by instructor). The capstone will deploy all 44 resources INTO that existing resource group. You will NOT create a new resource group.

### **The Requirements**

Your company is building a **Document Processing SaaS**:

```
Features:
  - Users upload documents (images, PDFs)
  - Backend processes them (extracts text, runs OCR)
  - Results stored in database
  - Frontend (web app) displays results
  - API for partners

Non-functional Requirements:
  - Handle 1,000 concurrent users
  - 99.9% uptime
  - PII compliance (encryption, audit logging)
  - Cost: < $5,000/month
  - Deployable to dev, staging, production
  - Zero-downtime deployments

Timeline: "Go live in 2 weeks."
```

### **What the Team Needs**

```
1. ✅ Design: "What Azure resources do we need?"
2. ✅ Code: "Give us the Terraform"
3. ✅ Validation: "Will this actually work?"
4. ✅ Security: "Does it meet company standards?"
5. ✅ Cost: "How much will it cost?"
6. ✅ Documentation: "How do we maintain it?"
```

### **How We'll Solve It**

```
Step 1: Ask the agent to design the architecture
        ↓
Step 2: Agent generates Terraform code
        ↓
Step 3: MCP server looks up module details and best practices from Terraform Registry
        ↓
Step 4: Agent applies relevant skills (security baseline, multi-tier)
        ↓
Step 5: Team reviews and asks for changes
        ↓
Step 6: Deploy to real Azure subscription
        ↓
Step 7: Celebrate! (actually delivered in 30 min)
```

---

## **Part 2: Design Phase - Working with the Agent (6-8 min)**

### **You: Ask the Agent**

In VS Code with the TerraformArchitect agent:

```
@TerraformArchitect

I need to design infrastructure for a Document Processing SaaS.

Requirements:
✓ Web frontend (React app)
✓ REST API backend (Node.js/Python)
✓ Document storage (blobs)
✓ Processing (background jobs)
✓ Database (structured data)
✓ 1,000 concurrent users
✓ 99.9% uptime SLA
✓ PII encryption required
✓ Audit logging for compliance
✓ Budget: $5,000/month max
✓ Dev, staging, production environments

Please:
1. Design the overall architecture
2. List Azure resources needed
3. Explain scalability approach
4. Address security requirements
5. Estimate monthly cost
6. Create Terraform modules for this design
7. Validate with terraform validate

Use our skills:
- deploy-multi-tier-app
- network-security-baseline
```

### **Agent: Generates Design**

```
## Document Processing SaaS - Architecture Design

### High-Level Overview

Your application follows a **multi-tier architecture**:

Tier 1 (Presentation):
  - Azure Front Door (global CDN)
  - Static Web App (React frontend)
  - Cost: ~$50/month

Tier 2 (API Layer):
  - App Service (auto-scaling)
  - API Management (rate limiting)
  - Cost: ~$100-200/month

Tier 3 (Processing):
  - Azure Functions (serverless processing)
  - Service Bus (async messaging)
  - Cost: ~$50-100/month

Tier 4 (Storage):
  - Blob Storage (hot tier for documents, cool for archives)
  - Cost: ~$50/month + usage

Tier 5 (Data):
  - SQL Database (structured data, backups)
  - Redis Cache (session/caching)
  - Cost: ~$300/month

Tier 6 (Security & Monitoring):
  - Azure Key Vault (secrets)
  - Log Analytics (audit logs)
  - Application Insights (monitoring)
  - Cost: ~$50/month

Total Estimated Cost: $650-1000/month
(Well under the $5,000 budget)

### Scaling Strategy

For 1,000 concurrent users:

1. Front Door provides:
   - Geographic redundancy
   - DDoS protection
   - Automatic failover

2. App Service auto-scales:
   - Min: 2 instances (high availability)
   - Max: 20 instances (peak load)
   - Scales based on CPU > 70%

3. Database:
   - Standard tier (enough for 1,000 users)
   - Read replicas for reporting (later)
   - Geo-redundant backups

4. Storage:
   - Hot tier for recent documents
   - Cool tier for archives (cheaper)

### Security Implementation

Follows **network-security-baseline** skill:

1. Network Isolation:
   - All services in private subnets
   - No public IPs
   - Private endpoints for database/storage

2. Secrets Management:
   - Connection strings in Key Vault
   - App Service uses Managed Identity
   - No secrets in environment variables

3. Encryption:
   - TLS 1.2+ for all traffic
   - SQL encryption at rest
   - Blob encryption at rest
   - Key rotation via Key Vault

4. Audit Logging:
   - All access logged to Log Analytics
   - Alerts for PII access
   - 90-day retention for compliance

### Terraform Modules

I've generated 6 modules:

1. **network.tf** - VNet, subnets, NSGs
2. **app-tier.tf** - App Service, API Management
3. **processing.tf** - Functions, Service Bus
4. **storage.tf** - Blobs, SQL, Redis
5. **security.tf** - Key Vault, RBAC
6. **monitoring.tf** - App Insights, Logs

All code is complete and ready to deploy.

### Validation Results

Running terraform validate...

✅ All syntax valid
✅ All resources properly defined
✅ Dependencies correct (storage before app)
✅ Outputs defined for all important resources

Running terraform plan...

Plan: 44 resources to create (all within your assigned resource group)
  - 1 Virtual Network
  - 3 Subnets
  - 1 App Service Plan
  - 1 App Service
  - 1 API Management
  - 1 Function App
  - 5 Storage Accounts
  - 1 SQL Database
  - 1 Redis Cache
  - 1 Key Vault (with 20 secrets)
  - 1 Log Analytics Workspace
  - 1 Application Insights
  - ... and more for NSGs, endpoints, RBAC

All validation passed! ✅
```

---

## **Part 3: Code Review & Modifications (2-3 min)**

### **What the Team Might Ask**

```
"Wait, we use Azure DevOps Pipelines, not GitHub Actions.
 Can you add that?"

"Our compliance team requires 1-year log retention, not 90 days."

"We're expecting 5,000 users peak, not 1,000."

"We want multi-region failover, not just one region."
```

### **Agent: Adapts & Regenerates**

```
You: "@TerraformArchitect, update for:
     - Log retention: 365 days
     - Max users: 5,000 (add more App Service instances)
     - Add Redis replicas for high availability"

Agent: "Updated design for 5,000 users and advanced resilience:

Scaling Changes:
- App Service now scales up to 50 instances (from 20)
- Redis upgraded to Premium tier with replication
- Added SQL read replica for reporting
- Log retention bumped to 365 days

New Estimated Cost: $1,200-1,500/month (still under budget)

Updated Terraform modules:

[regenerates all 6 modules with changes]

Validation Results:
✅ All syntax valid
✅ All resources properly defined
✅ Dependencies correct

Running terraform plan to show new resources...

Plan: 52 resources to create (7 additional resources for HA)
[shows detailed diff]
"
```

---

## **Part 4: Deployment (4-5 min)**

### **⚠️ Important Setup Note**

Before initializing, ensure your Terraform code is configured to:
1. Reference your pre-existing resource group (using `data "azurerm_resource_group"`)
2. Deploy all resources INTO that resource group
3. NOT create a new resource group

**Your resource group name:** [Provided by instructor before workshop]

### **Step 1: Initialize Terraform**

```bash
# Everyone (instructor + participants) at the same time:
cd capstone-deployment

# First, set your resource group name in terraform.tfvars:
cat > terraform.tfvars << 'EOF'
resource_group_name = "rg-terraform-workshop-{N}"  # Replace {N} with your attendee number
environment         = "dev"
app_name            = "document-processor"
EOF

# Then initialize
terraform init

# Output:
# ✓ Successfully initialized terraform working directory
# ✓ Azure provider initialized
# ✓ State file created
```

### **Step 2: Review the Plan**

```bash
terraform plan -out=tfplan

# Output shows all 44 resources that will be created
# (inside your existing resource group)
# Everyone reads it together: 
# "Does this match the design we reviewed?"
# (thumbs up from everyone)
```

### **Step 3: Apply the Deployment**

```bash
terraform apply tfplan

# This takes 10-15 minutes (Azure provisioning is slow)
# While waiting, discuss:
#   - How Azure is creating resources in parallel
#   - State file tracking everything
#   - What happens if we cancel mid-deployment
#   - Why we're using the existing resource group
```

### **Step 4: Verify in Azure Portal**

While Terraform is applying:

```bash
# In another terminal, watch Azure Portal
# Open: https://portal.azure.com

# Navigate to your assigned resource group
# (provided by instructor at workshop start)

# Watch resources appear inside your resource group:
# - VNet
# - App Service
# - SQL Database
# - Storage Accounts
# - Key Vault
# ...and more

# Instructor narrates: "Look, 44 resources appearing in real-time,
# all deployed into your resource group.
# This would take a human 4-6 hours to create manually.
# We did it in code, reviewed it, and deployed safely in 30 minutes.
# And it's reproducible—same code, same result every time."
```

### **Step 5: Test the Deployed Infrastructure**

```bash
# Get outputs from Terraform
terraform output

# Example outputs:
# app_service_url = "https://app-document-proc-dev.azurewebsites.net"
# database_server = "sqlsrv-doc-proc-dev.database.windows.net"
# storage_account_url = "https://stgdocprocdev.blob.core.windows.net/"
# keyvault_url = "https://kv-doc-proc-dev.vault.azure.net/"

# Test the app (if we have a sample app deployed):
curl https://app-document-proc-dev.azurewebsites.net/health
# Response: { "status": "healthy", "version": "1.0" }
```

---

## **Part 5: Show Real-World Variations (3-4 min)**

### **Multi-Environment Setup**

```bash
# Same code, different .tfvars files create different environments:

# Development deployment:
terraform apply -var-file=terraform.dev.tfvars

# Staging deployment:
terraform apply -var-file=terraform.staging.tfvars

# Production deployment (requires approval):
terraform apply -var-file=terraform.prod.tfvars
```

### **What Differs Per Environment**

| Variable | Dev | Staging | Production |
|----------|-----|---------|------------|
| Environment | dev | staging | prod |
| App Service SKU | B1 | S1 | P1V2 |
| DB Edition | Standard | Standard | Premium |
| Min Instances | 1 | 2 | 3 |
| Max Instances | 5 | 10 | 50 |
| Cost/Month | $200 | $400 | $1,200 |

**Same Terraform code, different configurations = Infrastructure as Code in action!**

---

## **Part 6: Teardown & Automation (2-3 min)**

### **Clean Up**

```bash
# After the demo, destroy everything:
terraform destroy -var-file=terraform.dev.tfvars

# Type: yes

# All 45 resources deleted in ~5 minutes
# Clean Azure subscription
# No manual cleanup needed
```

### **Automation Opportunities**

```bash
# You could automate this deployment with CI/CD:

.github/workflows/deploy-infrastructure.yml
├── Trigger: When terraform/ files change in a PR
├── Run: terraform validate (linting)
├── Run: terraform plan (preview changes)
├── Require: Human approval (code review)
├── Run: terraform apply (actually deploy after approval)
└── Slack notification: "Infrastructure deployed successfully"

# Now your entire deployment is:
#   git push → automation → Azure resources
#   All audited, all version controlled
```

---

## **Part 7: Wrap-Up & Key Learnings (2-3 min)**

### **What You Just Did**

```
✅ Used AI (agent) to design complex infrastructure
✅ Leveraged MCP server to get module documentation and best practices from Registry
✅ Applied team skills (security baseline, multi-tier pattern)
✅ Generated 45+ production-grade Azure resources
✅ Verified deployment with HCP Terraform
✅ Verified resources in Azure Portal
✅ Documented everything in code
✅ Made it reproducible and auditable

Timeline: 30 minutes
Manual time (old way): 1-2 weeks
Time saved: 99%

Errors prevented: How many network configs would have mistakes?
  With the agent: 0 (validated automatically)
  Without the agent: 3-5 (caught in code review, after hours of rework)
```

---

## 🏁 Transition to Wrap-Up

**Closing statement:**

```
"This capstone shows the future of infrastructure teams.

You're not:
  ❌ Clicking through portal screens
  ❌ Hoping you remember the configuration
  ❌ Trusting manual documentation
  ❌ Discovering security issues in production

You're:
  ✅ Designing in code (reviewed, audited, versioned)
  ✅ Using AI to accelerate design and catch errors
  ✅ Applying team patterns consistently
  ✅ Deploying with confidence
  ✅ Onboarding new team members faster

If you ran this as a post-workshop lab, close by directing participants
to the wrap-up checklist and next steps."
```

---

## 🎯 Quick Verification Checklist

Before ending this Chapter, confirm:

- [ ] 45+ resources deployed to Azure successfully
- [ ] Resources visible in Azure Portal
- [ ] terraform output shows expected values
- [ ] Participants understand the workflow
- [ ] Understands how to modify variables for different envs
- [ ] terraform destroy cleaned up properly

---

## ❓ Likely Q&A

**Q: "What if the terraform apply fails mid-way?"**  
A: "Terraform state file tracks what was created. Re-run apply and it picks up where it failed. That's the power of state."

**Q: "How do we manage state files in production?"**  
A: "Store in Azure Storage account (not locally), with encryption and access control. We'll cover that in team governance."

**Q: "Can we version this infrastructure?"**  
A: "Yes! The Terraform code is in git. Each commit is a version. You can branch, tag, and compare versions like any codebase."

**Q: "What if two teams deploy to the same subscription?"**  
A: "Separate resource groups per team. Or use different subscriptions. Terraform isolates by tfvars and state files."

---

## 💡 Pro Tips for Delivery

1. **Go slow on the apply.** The moment resources appear in the portal is magical. Let them sink in.
2. **Show the problem it solves.** "Manually, this would take a week. We did it safely in 30 minutes."
3. **Celebrate the safety.** "No typos, no forgotten configurations, no security oversights. All prevented automatically."
4. **Real-time narration.** As terraform apply runs, explain what's happening behind the scenes.
5. **Save state for later.** Consider NOT destroying, so participants can explore in the portal during break.

---

**Next:** [Chapter 13: Wrap-Up & Next Steps](../06_Wrap_Up.md)

