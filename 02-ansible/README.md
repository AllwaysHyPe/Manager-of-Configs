# 02-ansible

This is where Terraform hands off to Ansible.

## Why Ansible for Windows

If you're coming from a ConfigMgr background, the question you're probably asking is: how do I manage my servers without a site server, a client agent, and a domain? Ansible is agentless, works over WinRM or SSH, runs from anywhere, and your entire configuration is YAML files in Git. Rest without making any changes using `--check --diff`.

No need to throw away your PowerShell scripts either — you can call them from a playbook and use Ansible's orchestration capabilities.

## Directory structure

```
02-ansible/
├── ansible.cfg               
├── requirements.yml          # Collection dependencies
├── inventory/
│   └── azure_rm.yml          # Dynamic inventory host files
└── playbooks/
    ├── 0-windows-baseline.yml
    ├── 1-arc-onboard.yml
    └── 2-windows-baseline.yml
```
## Local setup

The Azure collection requires Python 3.12. The collection doesn't support Python 3.13 or 3.14 yet — you'll get `AzureCliCredential is not defined` errors if you try.

```bash
# Install pyenv if you don't have it
brew install pyenv
pyenv install 3.12
pyenv local 3.12

# Create a fresh venv from inside the 02-ansible directory
cd 02-ansible
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install ansible pywinrm
ansible-galaxy collection install -r requirements.yml --force
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
```

Make sure you're logged into Azure CLI before running any inventory or playbook commands:

```bash
az login
az account set --subscription '<your sub id>'
```

Set the required environment variables for Arc server credentials:

```bash
export SRV_ADMIN_USER="Administrator"
export SRV_ADMIN_PASSWORD="<Arc server Administrator password>"
export ANSIBLE_WINDOWS_PASSWORD="<Terraform VM password>"
```

Then verify the inventory is working:

```bash
ansible-inventory -i inventory/azure_rm.yml --list
```

You should see all three hosts — `mgrcnfgs-vm-*`, `Srv02`, and `Server2025` — in the `role_webserver` group with the correct connection types.

## Dynamic inventory

`azure_rm.yml` is where Ansible asks Azure what exists at runtime. The tag `managed_by=ansible` is the only gate — if a server has it, Ansible picks it up. If it doesn't, Ansible ignores it completely.

Think of it like a device collection in ConfigMgr, except the query runs itself and you never have to update it manually. Terraform applies the tags when it provisions a VM. For Azure Arc servers you tag them with:

```bash
az connectedmachine update --resource-group mgr-of-configs --name Srv02 \
  --tags managed_by=ansible environment=mgr-of-configs role=webserver choco_agent=true
```

The `role` tag builds inventory groups. `role=webserver` becomes the group `role_webserver`. Your playbooks target groups not individual servers. 
- you can use anything else for role, this was just a placeholder for my demo 

`conditional_groups` creates group names:

```yaml
conditional_groups:
  ansible_managed: "'ansible' in (tags.managed_by | default(''))"
  arc_servers: "resource_type == 'Microsoft.HybridCompute/machines'"
  azure_vms: "resource_type == 'Microsoft.Compute/virtualMachines'"
```

`arc_servers` is what the SSH proxy pre_task loops over. `azure_vms` is there for future use.

## Two connection types, one inventory

This repo manages both Azure VMs and Azure Arc-enabled on-premises servers from the same inventory file. Azure VMs connect over WinRM. Arc enabled servers connect over SSH through Azure's relay service. The inventory figures out which to use based on the Azure resource type — you don't configure anything per server.

```yaml
ansible_connection: "'winrm' if resource_type == 'Microsoft.Compute/virtualMachines' else 'ssh'"
```

## Azure Arc SSH relay

`Srv02` and `Server2025` are Hyper-V VMs on my home network with no public IP. The Arc agent on each server maintains an outbound connection to Azure. When Ansible needs to connect, it goes through Azure's relay instead of directly to the server.

That means a GitHub Actions runner in Microsoft's cloud can manage a server behind my home router.

### Prerequisites for Arc SSH

Before the SSH relay works you need to do a few things once per server:

**1. Install OpenSSH** (Srv02 — Server 2022, not pre-installed):
```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic
```
Server2025 has OpenSSH built in — nothing to do.

**2. Create the default connectivity endpoint:**
```bash
az rest --method put \
  --uri "https://management.azure.com/subscriptions/<sub>/resourceGroups/mgr-of-configs/providers/Microsoft.HybridCompute/machines/<name>/providers/Microsoft.HybridConnectivity/endpoints/default?api-version=2023-03-15" \
  --body '{"properties": {"type": "default"}}'
```

**3. Enable the SSH service configuration:**
```bash
az rest --method put \
  --uri "https://management.azure.com/subscriptions/<sub>/resourceGroups/mgr-of-configs/providers/Microsoft.HybridCompute/machines/<name>/providers/Microsoft.HybridConnectivity/endpoints/default/serviceconfigurations/SSH?api-version=2023-03-15" \
  --body '{"properties": {"serviceName": "SSH", "port": 22}}'
```

**4. Register the HybridConnectivity resource provider:**
```bash
az provider register -n Microsoft.HybridConnectivity
```

**5. Set PowerShell as the default SSH shell** (connect via `az ssh arc` and run):
```powershell
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell `
  -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' `
  -PropertyType String -Force
```

### Service principal permissions for Arc SSH

The GitHub Actions service principal needs these roles on the `mgr-of-configs` resource group to set up the SSH relay:

```bash
az role assignment create \
  --assignee <ARM_CLIENT_ID> \
  --role "Azure Connected Machine Resource Manager" \
  --scope "/subscriptions/<sub>/resourceGroups/mgr-of-configs"

az role assignment create \
  --assignee <ARM_CLIENT_ID> \
  --role "Virtual Machine Local User Login" \
  --scope "/subscriptions/<sub>/resourceGroups/mgr-of-configs"
```

The `azure_rm_arcssh` module also uses `auth_source: cli` so it picks up the OIDC session from the `azure/login` step rather than looking for SDK credentials separately.

## Playbooks

### `0-windows-baseline.yml`

The GPO replacement. Every task maps to something you'd previously manage in GPMC — services, registry settings, firewall profiles, Windows features. It lives in Git, has a change history, runs against any Windows server regardless of domain membership, and tells you exactly what it would change before it changes anything.

**`pre_tasks` — Arc SSH proxy**

Before `gather_facts` runs, the pre_task sets up SSH proxy tunnels for all Arc servers. It runs on `localhost` (the control node), loops over the `arc_servers` group, and creates the ssh_config files the SSH connection needs. `run_once: true` means it runs once for all Arc servers rather than once per server.

**`become` — conditional elevation**

Service management (`win_service`) requires elevation over WinRM but doesn't work over SSH the same way. The `when: ansible_connection == 'winrm'` condition skips service tasks on Arc servers entirely — they get the registry, firewall, and feature tasks which work fine over SSH without SYSTEM elevation. The Terraform VM gets all tasks with `become: runas` as SYSTEM.

**`gather_facts: false` + explicit setup**

`gather_facts: false` is set so the SSH proxy runs in `pre_tasks` before Ansible tries to connect. Without this, `gather_facts` runs first and the ssh_config files don't exist yet. The explicit `ansible.builtin.setup` task at the end of `pre_tasks` then gathers facts after the proxy is ready.

### `1-arc-onboard.yml`

Uses the `azure.azcollection.azure_arc` role to enroll servers into Azure Arc. Idempotent — already-enrolled servers are skipped. You need an existing management channel to the server before this runs. For my Hyper-V VMs the first enrollment was done manually via the Hyper-V console.

## ansible.cfg

```ini
[defaults]
deprecation_warnings = False
host_key_checking = False
```

`deprecation_warnings = False` silences the Azure collection's internal Python import warnings — honestly, I got sick of the notifications and I'm sure that there's a more eloquent way of handling this.

`host_key_checking = False` is needed for the Arc SSH connections. The GitHub Actions runner is a fresh ephemeral VM on every run and has no `known_hosts` file. Without this the SSH connection fails because it can't verify the host fingerprint.

## GitHub Actions

`ANSIBLE_CONFIG: 02-ansible/ansible.cfg` is set in the workflow env so the runner picks up `ansible.cfg` correctly. The Az SSH extension is installed on the runner before playbooks run. `check_mode` defaults to true — see what would change before it changes.
