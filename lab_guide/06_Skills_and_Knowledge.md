# Chapter 6: Skills & Knowledge Management
**Duration:** 25-30 minutes  
**Objective:** Create reusable skills that encapsulate IaC patterns and persist across sessions

---

## 📍 Learning Outcomes

By the end of this Chapter, participants will be able to:
- [ ] Understand skills as documented patterns and best practices
- [ ] Master the SKILL.md format and structure
- [ ] Create 1-2 team-specific Azure/Terraform skills
- [ ] Version and evolve skills over time
- [ ] Integrate skills with agents and MCP servers
- [ ] Share skills with teams

---

## ⏱️ Timing Breakdown
- **Concepts: What are skills?:** 3-4 min
- **Skill anatomy and SKILL.md format:** 4-5 min
- **Create Skill 1: "Deploy Multi-Tier App":** 7-9 min
- **Create Skill 2: "Security Baseline":** 7-9 min
- **Integration with agents and versioning:** 2-3 min
- **Q&A:** 1-2 min

## Companion Files For This Chapter

- Show `.github/skills/avm-deploy/SKILL.md` as the simplest workshop-ready skill.
- Show `.github/skills/hcp-terraform-runbook/SKILL.md` for the governance-oriented companion skill.
- Use [ref-resources.md](./reference/ref-resources.md) for the shorter skill examples if time gets tight.

---

## 🎤 Speaker Notes & Slides

### **Opening Hook (1 min)**

```
"Right now, the knowledge about your infrastructure lives WHERE?

  ❌ In someone's head
  ❌ In Slack messages lost forever
  ❌ In a Confluence doc nobody updates
  ❌ In code that's so complex nobody touches it

What if you could:
  ✓ Document patterns as reusable artifacts
  ✓ Version them in git (like code)
  ✓ Teach the agent to use them
  ✓ Have everyone follow the same patterns
  ✓ Build on them incrementally

That's what Skills do. Skills are Institutional Knowledge™."
```

---

## **Part 1: What Are Skills? (3-4 min)**

### **Skills Defined**

```
A SKILL is:
  - A documented solution to a common problem
  - Version controlled (in git)
  - Reusable across projects
  - Known by your AI agents
  - Evolved by your team over time

Not:
  - Code libraries (use modules for that)
  - Documentation (though it's documented)
  - One-time solutions

Examples:

Skill: "Deploy a Web API to Azure App Service"
  - When should you use this pattern?
  - What Azure resources do you need?
  - What Terraform code implements it?
  - What security considerations matter?
  - What monitoring should be enabled?
  - Cost ballpark?
  - Team approval workflow?

Skill: "Implement network security baseline"
  - NSG rules for common scenarios
  - Private endpoint setup
  - Firewall configuration
  - Audit logging
  - Compliance checklist

Skill: "Set up Azure Kubernetes Service cluster"
  - Terraform modules for AKS
  - Networking setup (ingress, egress)
  - Identity and access (Workload ID)
  - Monitoring and logging
  - Cost optimization tips
```

### **Why Skills Matter**

| Without Skills | With Skills |
|---|---|
| "Everyone designs networking differently" | "Here's THE network pattern we use" |
| "Why did we set up logging this way?" | "See Skill#3: Logging and Monitoring" |
| "Can new hires learn our patterns?" | "Read the skills folder, understand patterns" |
| "How do we enforce standards?" | "Agent enforces skills in code review" |
| "Where's the documentation?" | "In git, version controlled, always current" |

---

## **Part 2: Skill Anatomy - SKILL.md Format (4-5 min)**

### **Anatomy of a SKILL.md File**

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

### **Example Skill: Deploy Multi-Tier App**

Let me create a real example:

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

## Resources Created

This pattern creates these Azure resources:

| Resource | Purpose | Estimated Cost |
|----------|---------|------------------|
| Virtual Network | Network boundary | $0 (free tier) |
| 3 Subnets | Network segmentation | Included in VNet |
| App Service | Web/API hosting | $20-200/month |
| SQL Database | Relational storage | $15-100+/month |
| Redis Cache | Session/data caching | $16/month (minimum) |
| App Gateway | Load balancer + WAF | $30-50/month |
| Key Vault | Secret management | $0.60/month |
| Log Analytics | Monitoring/logging | $30-100+/month |
| Storage Account | Backups/logs | $1-10/month |
| **Total (small deployment)** | | **~$140-500/month** |

---

## Terraform Implementation

Here's the complete, validated Terraform code:

### 1. Provider Setup (main.tf)

\`\`\`hcl
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
  subscription_id = var.subscription_id
}
\`\`\`

### 2. Networking (network.tf)

\`\`\`hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  tags = var.common_tags
}

resource "azurerm_subnet" "public" {
  name                 = "subnet-public"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]
}

resource "azurerm_subnet" "data" {
  name                 = "subnet-data"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
  
  private_endpoint_network_policies_enabled = false
}
\`\`\`

### 3. App Service (app.tf)

\`\`\`hcl
resource "azurerm_app_service_plan" "main" {
  name                = "plan-${var.app_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Linux"
  reserved            = true
  
  sku {
    tier = var.app_tier
    size = var.app_size
  }
  
  tags = var.common_tags
}

resource "azurerm_app_service" "main" {
  name                = "app-${var.app_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id
  
  site_config {
    dotnet_framework_version = "v6.0"
    always_on                = true
  }
  
  tags = var.common_tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id     = azurerm_app_service.main.id
  subnet_id          = azurerm_subnet.app.id
}
\`\`\`

### 4. Database (database.tf)

\`\`\`hcl
resource "azurerm_sql_server" "main" {
  name                         = "sqlsrv-${var.app_name}-${var.environment}"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
  
  tags = var.common_tags
}

resource "azurerm_sql_database" "main" {
  name            = "db-${var.app_name}"
  server_id       = azurerm_sql_server.main.id
  collation       = "SQL_Latin1_General_CP1_CI_AS"
  edition         = var.sql_edition
  max_gb_included = var.sql_max_gb
  
  tags = var.common_tags
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pep-sql"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.data.id
  
  private_service_connection {
    name                           = "psc-sql"
    private_connection_resource_id = azurerm_sql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
  
  tags = var.common_tags
}
\`\`\`

### 5. Complete variables (variables.tf)

See referenced variables file with all inputs defined.

---

## Related Skills

- 🔒 **Skill: Implement Network Security Baseline** — NSG rules, firewall setup
- 🗝️ **Skill: Azure Key Vault Integration** — Secret management
- 📊 **Skill: Monitoring and Alerting** — Application Insights, Log Analytics
- 🔄 **Skill: CI/CD Pipeline with Azure DevOps** — Automated deployment

---

## Cost Estimation

### Small Environment (dev)
\`\`\`
App Service (B1): $10/month
SQL Database (Basic 5 DTU): $5/month
Redis Cache (C0): $16/month
Storage (100 GB): $2/month
Log Analytics (1 GB/day): $20/month
Total: ~$53/month
\`\`\`

### Large Environment (production)
\`\`\`
App Service (P1V2): $100/month
SQL Database (S4): $300/month
Redis Cache (C1): $30/month
App Gateway: $40/month
Log Analytics (50 GB/day): $200/month
Total: ~$670/month
\`\`\`

**Cost Optimization Tips:**
- Use B-series for dev (cheaper)
- Turn off Always On outside business hours
- Reduce database retention windows
- Use Reserved Instances for production

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

### "Private endpoint not connecting"
\`\`\`
Causes:
  - NSG rule blocking traffic
  - DNS resolution failing
  - Wrong subnet configuration

Fix:
  1. Check NSG rules allow traffic to data subnet
  2. Resolve the private endpoint DNS name
  3. Verify subnet has private endpoint enabled
\`\`\`

### "App can't connect to database"
\`\`\`
Causes:
  - Firewall rule too restrictive
  - Connection string incorrect
  - Database credentials wrong

Fix:
  1. Check firewall allows app subnet
  2. Use Key Vault for connection string
  3. Test credentials in SQL Server Management Studio
\`\`\`

---

## Team Notes

**Lessons Learned:**
- Private endpoints add latency (~2-3ms) but gain security
- Redis caching multiplies app throughput 5-10x
- Log retention costs dominate monitoring budget; set retention to 30 days
- Use Managed Identities instead of credentials when possible

**Team Standards for This Pattern:**
- All databases must have private endpoints (no exceptions)
- All connection strings come from Key Vault
- All resources must have Environment and Owner tags
- All environments (dev/stage/prod) must follow same architecture

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

### **That's a complete Skill!**

The skill:
  ✅ Explains the problem
  ✅ Shows the architecture
  ✅ Provides complete Terraform code
  ✅ Gives cost estimates
  ✅ Documents security requirements
  ✅ Lists related skills
  ✅ Provides troubleshooting
  ✅ Is version controlled

---

## **Part 3: Create Skill 2 - Security Baseline (7-9 min)**

### **Walk through creating a second, simpler skill**

```bash
mkdir -p skills/network-security-baseline
cat > skills/network-security-baseline/SKILL.md << 'EOF'
# Skill: Network Security Baseline

**ID:** skill-network-security-baseline  
**Version:** 1.0  
**Status:** ✅ Production  
**Author:** Security Team  
**Updated:** 2025-03-31

---

## What This Skill Solves

Implement minimal security baseline for all Azure network deployments:
  - Default-deny NSG rules
  - Allow only required traffic
  - Firewall protection
  - Audit logging
  - Compliance baseline (SOC 2, CIS)

---

## Problem Statement

Network security violations are common because:
  ❌ Default NSG rules are too permissive
  ❌ Nobody documents which ports/apps need access
  ❌ Audit logging is forgotten
  ❌ Nobody knows compliance requirements

This skill provides a baseline every network must follow.

---

## Solution Architecture

Use "Default Deny" model:

1. Start with NSG rules that DENY all traffic
2. Explicitly ALLOW only required connections:
   - Inbound: Only from load balancer / VPN
   - Outbound: Only to required destinations
3. Log all denied traffic
4. Alert on suspicious patterns

---

## Terraform Implementation

### NSG with Default Deny

\`\`\`hcl
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  # DEFAULT: All inbound is denied (implicit rule)
  # DEFAULT: All outbound is allowed (implicit rule)
  
  # Explicitly allow web traffic from load balancer
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = azurerm_public_ip.appgw.ip_address
    destination_address_prefix = "*"
  }
  
  # Explicitly deny RDP (prevent compromise)
  security_rule {
    name                       = "DenyRDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  # You get the idea: allow specific, deny everything else
  
  tags = var.common_tags
}
\`\`\`

### Audit Logging

\`\`\`hcl
resource "azurerm_network_watcher_flow_log" "app" {
  network_watcher_name       = azurerm_network_watcher.main.name
  resource_group_name        = azurerm_resource_group.main.name
  name                        = "flowlog-app"
  network_security_group_id   = azurerm_network_security_group.app.id
  storage_account_id          = azurerm_storage_account.logs.id
  enabled                     = true
  version                     = 2
  
  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.main.id
    workspace_region      = azurerm_resource_group.main.location
    workspace_resource_id = azurerm_log_analytics_workspace.main.id
    interval_in_minutes   = 10
  }
  
  tags = var.common_tags
}
\`\`\`

---

## Security Checklist

- [ ] All NSGs follow default-deny model
- [ ] Audit logging enabled for all NSGs
- [ ] Flow logs captured to Log Analytics
- [ ] Firewall rules documented
- [ ] Approved by Security team
- [ ] No RDP/SSH exposed to internet
- [ ] No HTTP (only HTTPS)

---

## Related Skills

- 🔐 **Skill: Deploy Multi-Tier Application** — Uses this security baseline
- 🔑 **Skill: Secrets Management** — For VPN access credentials

---

## References

- [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/overview)
- [Flow Logs Documentation](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
EOF
```

---

## **Part 4: Integrate Skills with Agents (2-3 min)**

### **Update Agent Instructions to Use Skills**

```bash
# Edit .instructions.md to reference skills

cat >> .instructions.md << 'EOF'

## Available Skills

When a user asks about patterns, reference the relevant skill:

- **Deploying an application?** → Point to `skills/deploy-multi-tier-app/SKILL.md`
- **Network security?** → Point to `skills/network-security-baseline/SKILL.md`
- **Setting up a database?** → Point to `skills/database-best-practices/SKILL.md`

Example response:
"Your networking needs follow our Security Baseline skill. 
See: skills/network-security-baseline/SKILL.md

Here's a brief summary of our standards:
1. Default-deny NSG rules
2. Explicit allow for each required port
3. Complete audit logging
..."
EOF

# Now when Copilot responds, it will mention and use the skills!
```

---

## **Part 5: Version Control Skills (1-2 min)**

```bash
# Commit skills to git
git add skills/
git commit -m "docs: Add Terraform skills library (multi-tier, security-baseline)"

# Share with team
git push origin main

# Everyone now has access to these skills!
```

### **Evolve Skills**

As your team learns:

```bash
# After you discover a better approach, update the skill
nano skills/deploy-multi-tier-app/SKILL.md

# Bump the version
# OLD: **Version:** 1.0
# NEW: **Version:** 1.1

# Add a "What Changed" Chapter
# Commit and push

git add skills/
git commit -m "docs: Update multi-tier skill v1.1 - add Redis caching"
git push
```

---

## 🏁 Transition to Chapter 7

**Closing statement:**

```
"You've now created SKILLS — institutional knowledge captured and versioned.

These skills:
  ✓ Document patterns your team uses
  ✓ Are version controlled (you know who changed what)
  ✓ Teach new team members
  ✓ Help agents give better advice
  ✓ Become your infrastructure bible

Now, let's bring it all together.

In the next Chapter (Custom Agents), you're going to:
  1. Learn what a custom VS Code agent is
  2. Create .agent.md, .instructions.md, and .prompt.md files
  3. Define agent scope, capabilities, and behavioral guardrails
  4. Integrate MCP tools into agent behavior
  5. Use a specialized agent for infrastructure planning and code generation

This is where it all clicks. Let's go!"
```

---

## 🎯 Quick Verification Checklist

Before moving to Chapter 7, confirm:

- [ ] Created `skills/` folder structure
- [ ] Created SKILL.md for Skill 1 (Multi-Tier App)
- [ ] Created SKILL.md for Skill 2 (Security Baseline)
- [ ] Both skills committed to git
- [ ] Agent instructions reference the skills
- [ ] Agent can help users find the right skill

---

## ❓ Likely Q&A

**Q: "How do I know when to create a new skill?"**  
A: "When your team repeats 'How do we do X?' twice, create a skill. When multiple projects follow the same pattern, that's a skill."

**Q: "Can skills be reused across teams?"**  
A: "Absolutely! Open-source your skills. Other teams benefit, and you get feedback to improve them."

**Q: "Version 1.0, 1.1, 2.0 — what's the difference?"**  
A: "1.1 = small improvements (clarifications, better examples). 2.0 = major rewrites (different architecture)."

**Q: "Do I need approval to update a skill?"**  
A: "Recommended: Have the team review changes. But you control the process. For internal projects, commit and discuss later."

---

## 💡 Pro Tips for Delivery

1. **Start small.** Two skills are better than zero. Five half-finished skills are worse than two complete ones.
2. **Make skills lived.** Update them monthly. Show versions in git.
3. **Reference skills constantly.** Every suggestion should point back to relevant skills.
4. **Build on each other.** Skill 1 (Multi-Tier) references Skill 2 (Security). Create a web of knowledge.
5. **Celebrate reuse.** When someone applies a skill to a new project, call it out. "That's the multi-tier pattern from the skills library!"

---

**Next:** ⏱️ If time permits → [Chapter 7: Custom Agents (Stretch Goal)](./07_Custom_Agents.md) | Otherwise → [Chapter 8: Wrap Up](./08_Wrap_Up.md)

