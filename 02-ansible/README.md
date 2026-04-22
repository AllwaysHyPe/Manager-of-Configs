# 02-ansible

Configuration management for Windows servers using Ansible.
This section covers the GPO replacement story — the same settings
you manage in GPMC, written as readable YAML that runs anywhere.

## Prerequisites

```bash
pip3 install ansible ansible-lint pywinrm
ansible-galaxy collection install azure.azcollection
az login
```

## Inventory

The inventory is dynamic — driven by tags on Azure Arc-enrolled servers.
No hosts file to maintain.

```bash
# See what servers the inventory finds
ansible-inventory -i inventory/azure_rm.yml --list

# Verify connectivity
ansible -i inventory/azure_rm.yml role_webserver -m win_ping
```

Servers need these tags to appear in playbook targets:

| Tag | Value | Group |
|---|---|---|
| `role` | `webserver` | `role_webserver` |
| `managed_by` | `ansible` | `ansible_managed` |

## Playbooks

### 0-audit.yml — compliance report, nothing changes

```bash
ansible-playbook playbooks/0-audit.yml \
  -i inventory/azure_rm.yml \
  --check --diff
```

Run this first. Always. Green means compliant. Yellow means drift detected.
Hand the output to your auditor.

### 1-cis-enforce.yml — apply CIS policy and fix drift

```bash
ansible-playbook playbooks/1-cis-enforce.yml \
  -i inventory/azure_rm.yml
```

Safe to run repeatedly. Servers already compliant generate zero changes.
Run nightly to catch and remediate drift automatically.

### 2-windows-baseline.yml — GPO equivalent configuration

```bash
ansible-playbook playbooks/2-windows-baseline.yml \
  -i inventory/azure_rm.yml
```

Every task maps to a GPO setting. Run with `--check --diff` to audit
without making changes.

## Policy Files

Controls live in `policies/controls/` — one file per CIS control.
Role compositions live in `policies/roles/`.
Documented exceptions live in `policies/exceptions/`.

The playbook reads from the policy files. To change a policy, edit
the control file. The playbook never needs to change.

## Useful Flags

```bash
# Audit only — no changes
--check --diff

# Target a specific server
--limit srv02

# Run specific tasks by tag
--tags services
--tags registry
--tags firewall
```