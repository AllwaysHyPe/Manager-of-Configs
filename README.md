# From ConfigMgr to Manager of Configs
 
> Reimagine server management from fine-grained configuration to a flexible
> approach that enables any server to run what it needs, regardless of location.
 
Session materials from the **From ConfigMgr to Manager of Configs** talk by
[Hailey Phillips](https://bsky.app/profile/allwayshype.com) and [Frank Lesniak](https://bsky.app/profile/franklesniak.com).
 
 
## What This Is
 
If you've seen any of my sessions on Azure Arc and Azure Update Manager, you've
probably heard the same questions I kept getting: "This is really cool, but how
do I manage my servers and third-party apps without ConfigMgr?"
 
That's what this repo is. Not a "throw everything away and start over" resource.
A "here's how you take the skills you already have and scale them" resource.
 
The barriers I hear consistently are real:
 
- Where do I even start?
- I've built all of these PowerShell scripts and I don't want to throw that time away
- I'm a small team (or a team of one) and I have zero bandwidth to learn something new
- What if I oversell this and can't deliver?
All valid. This repo addresses all of them.
 
The answer isn't a new tool. It's a pattern. Separate the things ConfigMgr
conflated into one (state, updates, and applications) and suddenly every tool
in this stack is doing exactly one thing it's actually good at.
 
 
## The Stack
 
**Terraform** for what Terraform is good at: plan, build, destroy. Terraform is
excellent at making infrastructure exist in a declared state and managing the
full resource lifecycle. It is not good at waiting for things to come up,
handling reboots, or complex configuration sequencing. So we don't ask it to do
those things. It provisions, enrolls into Azure Arc, sets the tags that drive
everything downstream, and hands off cleanly.
 
**Ansible** for everything Terraform is not good at: configuration, sequencing,
waiting, reboots, CIS policy enforcement, Chocolatey bootstrap, CCM agent setup.
Ansible is agentless, works natively with Windows over WinRM, and handles the
kind of complex multi-step work that ConfigMgr task sequences used to own. The
best part: you don't have to throw away your PowerShell scripts. You can call
them from a playbook and get all of Ansible's orchestration on top of work you
already did.
 
**Azure Update Manager** for patch management across Arc-enrolled servers,
consistent with how Azure-native VMs are patched. One of the first objections
to cloud adoption, removed.
 
**Chocolatey for Business** for application management. Internalized packages
that live in your own infrastructure, never phone home, and work whether your
servers are in Azure, on-prem, in a co-lo, or somewhere in between.
 
The goal is a set-and-forget-*ish* solution that gives you breathing room to
implement more cool things instead of spending all your time on reactive
maintenance.
 

 
## The Metaphor
 
Counting every gram of flour is not the skill. Baking the cake is the skill.
 
ConfigMgr shops carry enormous institutional knowledge about exactly how
everything is configured. That knowledge is valuable. But it lives in people's
heads and runbooks, not in code. When those people leave, the grams go with them.
 
A recipe is declarative. It says what done looks like. It does not care which
oven you use, which region the flour came from, or whether you are baking one
cake or a thousand.
 
Write the recipe once. Take the recipe anywhere for dessert anytime.
 

 
## Why Ansible for Configuration
 
AGENTLESS. You're getting closer to cloud-native instead of adding more agents
to manage.
 
You keep your PowerShell scripts. Run them from a playbook and supercharge them
with Ansible's ability to dynamically target hosts based on discovered parameters.
 
The same skills you build enforcing a CIS benchmark with Ansible are the same
skills you use to bootstrap Chocolatey, configure IIS, set up the CCM agent,
or run any other complex Windows configuration task. You're not learning a tool
for one job. You're learning a language your entire config story is written in.
 
For the GPO question specifically: Azure Policy with Guest Configuration can
enforce some of the same things, but it requires MOF files. If you haven't
touched DSC since the brief window where it was going to be the future and then
kind of wasn't, MOF files are not the skill you want to build. Ansible transfers.
 
 
## Where to Start
 
Not everything needs to change at once. Here's a practical framework:
 
**Keep:** Domain membership, anything GPO/ConfigMgr is doing that genuinely
belongs in policy, recent investments that are working.
 
**Replace:** Software deployment to servers, patch management, configuration
drift detection.
 
**Start here:** Azure Arc Machine Config in audit-only mode. Less risk. Installs
nothing. Changes nothing. Just shows you which servers are drifting from desired
state. Once you see that report you'll want to fix the drift. Once you want to
fix it automatically you'll want the rest of this stack.
 

 
## Repo Structure
 
```
terraform/
├── 00-base/                Resource group, the starting point
├── 01-storage-account/     Adds a handwritten storage account
├── 02-avm-storage/         Replaces it with an Azure Verified Module
└── 03-windows-vm/          Full VM stack, the cake tin
 
ansible/
├── inventory/
│   └── azure_rm.yml        Dynamic inventory driven by Arc tags
├── policies/
│   ├── controls/           One file per CIS control, the policy library
│   ├── roles/              Role compositions, which controls apply where
│   └── exceptions/         Documented deviations with approval records
└── playbooks/
    ├── cis_enforce.yml     Applies policy, reads from policies/
    ├── cis_audit.yml       Check mode only, free compliance report
    └── chocolatey/         Bootstrap and CCM agent setup
chocolatey/
└── README.md
```
 
Each folder has its own README with setup steps and context for that section.
 
 
## Getting Started with Terraform
 
### Prerequisites
 
- [Terraform CLI](https://developer.hashicorp.com/terraform/install) 1.14+
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An Azure subscription with Contributor access
### One-time backend setup
 
Terraform needs a storage account to keep its state file. Create this manually
before running anything else. This is the one thing Terraform can't create for
itself because it needs to exist before Terraform can start.
 
```bash
az login
 
az group create --name mgr-of-configs --location westus
 
az storage account create \
  --name mgrofconfigs \
  --resource-group mgr-of-configs \
  --location westus \
  --sku Standard_LRS \
  --allow-blob-public-access false
 
az storage container create \
  --name tfstate \
  --account-name mgrofconfigs
```
 
### Running the exercises
 
Each exercise folder is a complete standalone Terraform configuration. Start
with `00-base` and work forward. Each one builds on what the previous step
deployed.
 
```bash
cd terraform/00-base
cp backend.tfvars.example backend.tfvars
cp terraform.tfvars.example terraform.tfvars
 
terraform init
terraform fwt
terraform validate
terraform plan "-out=tfplan"
terraform apply tfplan
```
 
Repeat for each exercise folder. Each `plan` will show only the new resources
being added. Everything already deployed shows no changes. That's idempotency.
 
### Tear down
 
```bash
cd terraform/03-windows-vm && terraform destroy -auto-approve
cd ../02-avm-storage && terraform destroy -auto-approve
cd ../01-storage-account && terraform destroy -auto-approve
cd ../00-base && terraform destroy -auto-approve
```
 

 
## Getting Started with Ansible
 
### Prerequisites
 
Ansible runs on Linux or WSL. If you're on Windows, WSL is the easiest path.
For a full WSL setup walkthrough see:
[Modern Server Management with Ansible](https://www.allwayshype.com/allways-hype/modern-server-management-with-ansible)
 
```bash
pip3 install ansible ansible-lint
pip3 install pywinrm
ansible-galaxy collection install azure.azcollection
az login
```
 
### Dynamic inventory
 
Rather than maintaining a static hosts file, the inventory is driven by tags
on your Azure Arc-enrolled servers. Any server tagged `role=webserver` is
automatically in the `role_webserver` group. Add a server with the right tag
and the next Ansible run picks it up automatically. No inventory file to update.
 
```bash
# see what servers the dynamic inventory finds
ansible-inventory -i ansible/inventory/azure_rm.yml --list
```
 
### Running playbooks
 
```bash
# compliance report, check mode, nothing changes
ansible-playbook ansible/playbooks/cis_audit.yml \
  -i ansible/inventory/azure_rm.yml --check --diff
 
# enforce, apply policy and fix drift
ansible-playbook ansible/playbooks/cis_enforce.yml \
  -i ansible/inventory/azure_rm.yml
 
# bootstrap Chocolatey on webservers
ansible-playbook ansible/playbooks/chocolatey/bootstrap.yml \
  -i ansible/inventory/azure_rm.yml --limit role_webserver
```
 
### Enrolling servers into Arc via Ansible
 
Rather than running the Arc enrollment script manually on each server, Ansible
handles it:
 
```bash
ansible-playbook ansible/playbooks/azure/arc-onboard.yml \
  -i ansible/inventory/azure_rm.yml
```
 

 
## The Cost Question
 

[Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
and the
[Azure Bandwidth pricing page](https://azure.microsoft.com/en-us/pricing/details/bandwidth/).
 
| Component | Cost |
|---|---|
| First 100GB egress/month | Free |
| Internet egress after free tier (Zone 1) | $0.02/GB |
| Private endpoint (per endpoint) | ~$7.30/mo |
| Private Link data processing | $0.01/GB |
| Private DNS zone | $0.50/mo |
| **Total fixed overhead (2 endpoints + DNS)** | **~$16/mo** |
| Per 200MB package install | ~$0.002 |
| 1,000 servers, 20 packages/month | ~$56/mo total |
 
ConfigMgr is not free. CALs, SQL Server licensing, site server infrastructure, reliability, availability, 
and the time to maintain it not often accounted for in the cost calculation when someone argues against modernization.
 

 
## Resources
 
### Ansible
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Windows Modules](https://docs.ansible.com/ansible/2.9/modules/list_of_windows_modules.html)
- [Ansible Community: Chocolatey Collection](https://docs.ansible.com/ansible/latest/collections/chocolatey/chocolatey/index.html)
- [Configuring Remoting for Ansible](https://github.com/ansible/ansible/blob/stable-2.12/examples/scripts/ConfigureRemotingForAnsible.ps1)
- Jeremy Murrah: [Ansible for the Windows Admin](https://www.youtube.com/watch?v=ZI20Y10OKd0)
- Josh King: [Ansible 101 for the Windows SysAdmin](https://www.youtube.com/watch?v=SqO2HkKep90)
- Josh King: [Your Superpowered Windows Infrastructure Toolkit: Ansible, PowerShell, and Chocolatey](https://www.youtube.com/watch?v=oKJtlEenaog&t=4664s)
### Azure Arc
- [Azure Arc Overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
- [Onboard servers with Ansible](https://learn.microsoft.com/en-us/azure/azure-arc/servers/onboard-ansible-playbooks)
- [Azure Arc Pricing](https://azure.microsoft.com/en-us/pricing/details/azure-arc/core-control-plane/)
### Terraform
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Azure Naming Module](https://registry.terraform.io/modules/Azure/naming/azurerm/latest)
### Chocolatey
- [Chocolatey for Business](https://chocolatey.org/for-business)
- [Chocolatey Central Management](https://docs.chocolatey.org/en-us/central-management/)
- [Package Internalizer](https://docs.chocolatey.org/en-us/features/paid/package-internalizer)
### WSL Setup
- [Set up a WSL development environment](https://learn.microsoft.com/en-us/windows/wsl/setup/environment)
- [Allways HyPe: Modern Server Management with Ansible](https://www.allwayshype.com/allways-hype/modern-server-management-with-ansible)
