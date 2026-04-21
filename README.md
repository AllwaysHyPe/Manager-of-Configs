# From ConfigMgr to Manager of Configs
 
> Reimagine server management from fine-grained configuration to a flexible
> approach that enables any server to run what it needs, regardless of location.
 

 
## Why This Talk Exists
 
Most organizations know they need to modernize. Most organizations also have a
decade of ConfigMgr investments, thousands of GPO settings, and at least one
person who knows exactly why that one registry key is set to that one value —
and that person is worried about what happens when you take ConfigMgr away.
 
This talk does not take ConfigMgr away. It answers a different question.
 
**ConfigMgr manages servers. This stack manages intent.**
 
When you manage servers, every server is a unique snowflake you have to know
about individually. When you manage intent, you describe what done looks like
and every server converges to that description — whether it's in your datacenter,
an Azure region, a co-location facility, or someone's closet.
 
The transition from on-prem to cloud feels overwhelming because people try to
replicate ConfigMgr in the cloud. That's the wrong goal. The right goal is to
separate the three things ConfigMgr conflated into one tool:
 
- **What state should the OS be in?** — Configuration
- **What software should be running?** — Application artifacts
- **What patches are applied?** — Update management
Separate those concerns and suddenly the cloud isn't a migration problem.
It's just another place where your recipes run.
 

 
## What Attendees Will Learn
 
**A scalable management model that facilitates cloud adoption.** Shift from
server-centric thinking — where every machine is something you know about and
manage individually — to intent-driven patterns where you describe desired state
once and every server converges to it automatically, regardless of where it lives.
 
**How to modernize without a direct replacement for ConfigMgr or GPOs.** Not
everything needs to change. The talk gives a clear framework for what to retain,
what to replace, and how to navigate the transition without breaking what already
works. You do not need to boil the ocean.
 
**The synergy of policy, configuration, artifacts, and automation.** Four tools,
four concerns, one coherent pipeline. None of them need to know about the others.
Together they handle everything ConfigMgr did, plus things ConfigMgr never could —
like managing servers that aren't domain-joined, in clouds you don't own, at a
scale where manual work isn't an option.
 
**Practical techniques for making applications portable and efficient.** Internalized
packages that never phone home. Role-based software sets driven by tags. A package
management pipeline that works in an air-gapped datacenter and a public cloud
region using identical tooling.
 

 
## The Core Metaphor
 
Counting every gram of flour is not the skill. Baking the cake is the skill.
 
ConfigMgr shops carry enormous amounts of institutional knowledge about exactly
how everything is configured — every GPO setting, every task sequence step,
every distribution point. That knowledge is valuable. But it lives in people's
heads and runbooks, not in code. When those people leave, the grams go with them.
 
A recipe is declarative. It says what done looks like. It does not care which
oven you use, which region the flour came from, or whether you are baking one
cake or a thousand. The recipe is portable, version-controlled, and readable
by anyone on the team.
 
**Terraform** bakes the cake tin — provisions infrastructure, enrolls servers
into Azure Arc, and walks away. Its job is done the moment the server exists.
 
**Ansible** bakes the layers — applies configuration baselines, enforces CIS
policies, remediates drift. It picks up exactly where Terraform left off.
 
**Azure Update Manager** keeps it fresh — patches the OS on a schedule,
consistently, across every server regardless of location.
 
**Chocolatey for Business** pipes on the icing — installs the right applications
at the right versions for each server role, from an internal repository that
never depends on the internet.
 

 
## Why These Tools, Not Others
 
### Terraform — for what Terraform is good at
 
Terraform is excellent at one thing: making infrastructure exist in a declared
state. Plan, build, destroy. It manages the resource lifecycle declaratively,
stores state so it knows what it created, and handles dependencies automatically.
 
Terraform is not good at waiting. It does not handle "provision this VM, wait
for it to boot, wait for the Arc agent to phone home, then run a configuration
script." That handoff is where many IaC implementations get complicated. This
talk keeps Terraform in its lane — it provisions and Arc-enrolls, then hands off
cleanly to Ansible via Azure tags.
 
### Ansible — for everything Terraform is not good at
 
Ansible owns the configuration layer. It communicates over WinRM or SSH, handles
reboots mid-playbook, manages Windows-specific resources natively, and is
idempotent by default. It is also where the CIS benchmark enforcement lives —
not because Ansible is the only tool that can do it, but because the same Ansible
skill that enforces a CIS policy is the same skill that bootstraps Chocolatey,
configures IIS, sets up the CCM agent, and handles every other complex
configuration task that requires sequencing, waiting, and conditional logic.
 
Azure Policy with Guest Configuration can enforce some of the same things, but
it requires MOF files — a DSC artifact that most Windows admins haven't touched
since the brief window where DSC was going to be the future and then kind of
wasn't. Ansible transfers. MOF files don't.
 
### Chocolatey for Business — for applications
 
The icing is the last thing applied and the most visible thing. It is also what
makes a server a web server vs a build agent vs a database host. Chocolatey owns
application management — what software is installed, at what version, from what
source.
 
The key pattern is internalization: packages that embed or reference binaries
from your own infrastructure rather than the vendor's CDN. An internalized package
works in an air-gapped network, works after a vendor removes an old version,
works when the internet is having a bad day. It is the difference between a recipe
that requires a trip to the grocery store and one where all the ingredients are
already in your kitchen.
 

 
## The Four Concerns, Clearly Separated
 
```
┌─────────────────────────────────────────────────────────────────┐
│  INTENT                                                         │
│  "This server should exist, be patched, be configured,          │
│   and have these applications installed."                       │
└──────────────────────────────┬──────────────────────────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
   ┌─────────────┐    ┌─────────────────┐    ┌───────────────────┐
   │  Terraform  │    │     Ansible     │    │  Chocolatey C4B   │
   │             │    │                 │    │                   │
   │  Does the   │    │  Is the server  │    │  Is the right     │
   │  server     │    │  in the right   │    │  software         │
   │  exist?     │    │  state?         │    │  installed?       │
   └──────┬──────┘    └────────┬────────┘    └────────┬──────────┘
          │                    │                      │
          ▼                    ▼                      ▼
   Azure Arc enrolled    CIS baseline applied    Apps deployed
   Tags set              Drift remediated        via CCM
   Handed off            GPOs replaced           Internalized
                                                 Role-specific
 
                    ┌─────────────────────┐
                    │  Azure Update Mgr   │
                    │  Is the OS patched? │
                    └─────────────────────┘
                    Applies to all servers
                    regardless of location
```
 

 
## Talk Structure (~60 minutes)
 
**Opening — The Reframe (5 min)**
The grain-counting problem. ConfigMgr works. So does measuring every gram of
flour. The question is whether that is the skill you want to keep.
 
**Act 1 — The Update Problem (8 min)**
Azure Update Manager. The easiest win. One objection removed before the main event.
 
**Act 2 — The Configuration Problem (20 min)**
GPO tombstone. Ansible for CIS benchmarks using modular policy files. Arc dynamic
inventory. The skill transferability argument — this knowledge compounds everywhere.
 
**Act 3 — The Application Problem (15 min)**
Chocolatey for Business. The icing. Online vs internalized packages. The C4B +
Azure architecture. The cost argument — live in the Azure Pricing Calculator.
 
**Act 4 — Synergy and Adoption (5 min)**
The full pipeline. The decision framework. One actionable first step.
 

 
## Repo Structure
 
```
terraform/
├── 00-base/                Resource group only — starting point
├── 01-storage-account/     Adds handwritten storage account
├── 02-avm-storage/         Replaces handwritten with Azure Verified Module
└── 03-windows-vm/          Full VM stack — the cake tin
 
ansible/
├── inventory/
│   └── azure_rm.yml        Dynamic inventory from Arc tags
├── policies/
│   ├── controls/           One file per CIS control
│   ├── roles/              Role compositions
│   └── exceptions/         Documented deviations with approvals
└── playbooks/
    ├── cis_enforce.yml
    ├── cis_audit.yml
    └── chocolatey/         Bootstrap and CCM agent setup
 
chocolatey/
└── README.md
```
 

 
## Azure Environment
 
### Backend (permanent — manually created)
 
| Resource | Name | Purpose |
|---|---|---|
| Resource group | `mgr-of-configs` | Container for backend and Arc servers |
| Storage account | `mgrofconfigs` | Terraform state backend |
| Container | `tfstate` | State file location |
 
### Demo Arc Servers
 
| Server | Role tag | Notes |
|---|---|---|
| `Srv02` | `webserver` | Hyper-V VM, Arc-enrolled, Ansible target |
| `Srv2025` | `webserver` | Hyper-V VM, Arc-enrolled, Ansible target |
 
### Terraform-managed (ephemeral)
 
Created and destroyed per demo run. Resource group follows `mgrcnfgs-{pet}{string}`.
Random suffix means no naming conflicts between runs.
 

 
## Demo Workflows
 
### Terraform
 
```bash
cd terraform/00-base
terraform init "-backend-config=backend.tfvars"
terraform plan "-out=tfplan"
terraform apply tfplan
# repeat for each exercise folder
```
 
Reset between runs:
 
```bash
cd terraform/03-windows-vm && terraform destroy -auto-approve
cd ../02-avm-storage && terraform destroy -auto-approve
cd ../01-storage-account && terraform destroy -auto-approve
cd ../00-base && terraform destroy -auto-approve
```
 
### Ansible
 
```bash
# check what Arc servers the dynamic inventory sees
ansible-inventory -i ansible/inventory/azure_rm.yml --list
 
# audit — compliance report, no changes
ansible-playbook ansible/playbooks/cis_audit.yml \
  -i ansible/inventory/azure_rm.yml --check --diff
 
# enforce — apply policy
ansible-playbook ansible/playbooks/cis_enforce.yml \
  -i ansible/inventory/azure_rm.yml
 
# bootstrap Chocolatey on webservers
ansible-playbook ansible/playbooks/chocolatey/bootstrap.yml \
  -i ansible/inventory/azure_rm.yml --limit role_webserver
```
 

 
## Key Numbers for the Cost Objection
 
All verifiable in the Azure Pricing Calculator and Azure Bandwidth pricing page.
 
| Component | Cost |
|---|---|
| First 100GB egress/month | Free |
| Internet egress after free tier (Zone 1) | $0.02/GB |
| Private endpoint (per endpoint) | $0.01/hr (~$7.30/mo) |
| Private Link data processing | $0.01/GB |
| Private DNS zone | $0.50/mo |
| **Total fixed overhead (2 endpoints + DNS)** | **~$16/mo** |
| Per 200MB package install | ~$0.002 |
| 1,000 servers, 20 packages/month | ~$56/mo total |
 
ConfigMgr is not free. CALs, SQL Server licensing, site server infrastructure,
and FTE maintenance time are costs that rarely appear on the slide when someone
argues against modernization.
 

 
## Co-Presenter Notes
 
**The talk splits naturally at the Act 2 / Act 3 boundary.** One presenter can
own Terraform + Arc enrollment + Ansible. The other can own Chocolatey for
Business and the cost/architecture argument. Both sections are self-contained.
 
**Use the recipe metaphor as a transition.** Every section connects back to it.
It is the thread that makes three separate demos feel like one coherent story.
 
**The GPO tombstone is intentional.** It is not saying GPOs are wrong — it is
asking where the knowledge lives. That question lands differently for every
person in the room. Let it sit for a moment before moving on.
 
**The cost objection will come from the audience.** Build the estimate live in
the Azure Pricing Calculator rather than showing a static number. The audience
can verify it on their phones while you are talking. That is more convincing
than any slide.
 
**The first step for anyone in the audience is Arc Machine Config in audit-only
mode.** It installs nothing, changes nothing, and requires no commitment to any
of the other tools. It just shows which servers are drifting from desired state.
That is the hook that makes people want to do the rest.