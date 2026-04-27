# 03-chocolatey


## Why Chocolatey

ConfigMgr manages software deployments. It also requires a site server, a client agent, distribution points, and a domain. Chocolatey for Business replaces that entire stack with a package feed, a management service, and a lightweight agent. The agent gets installed by Ansible. Packages come from your internal Nexus repository. Nothing touches the internet during deployment. 



## C4B Azure environment

Setup by following the [Chocolatey for Business Environment - Azure Environment](https://docs.chocolatey.org/en-us/c4b-environments/azure/) docs and then added the variables to my GitHub Actions secrets.

## Playbooks

### `0-bootstrap.yml`

Installs Chocolatey and connects the server to CCM. Runs once per server. After this, package management happens through CCM deployments.

The bootstrap is written as explicit tasks on purpose. Each one maps to a step a ConfigMgr admin would recognize — install the client, add the internal source, disable the community repo, install the license, install the extension. It makes the talk easier to follow and each step shows up clearly in the Ansible output.

**The self-signed certificate**

The first task installs your C4B self-signed cert into `Root` and `TrustedPeople` before anything tries to talk to Nexus. Without it every HTTPS connection fails. The cert is stored as `C4B_CERT` in GitHub secrets as a base64-encoded DER file.

**Arc servers**

The `pre_tasks` block sets up the Arc SSH proxy before gather_facts runs — same pattern as the Ansible baseline playbook. Bootstrap runs over WinRM for the Terraform VM and over SSH through the Azure Arc relay for `Srv02` and `Server2025`. No changes to the playbook needed.

`become: true / become_method: runas / become_user: SYSTEM` is set at the play level. This works over WinRM and is needed for the Chocolatey install to write to system paths. For Arc servers connecting over SSH this causes issues, so if you need to run bootstrap against Arc servers you may need to adjust the become settings using the same conditional pattern from `0-windows-baseline.yml`.

### `1-packagemgmt.yml`

Package management with the `chocolatey.chocolatey` collection. Demonstrates installing packages, pinning versions so `choco upgrade all` doesn't touch them, passing install arguments, and passing package parameters. Everything comes from `ChocolateyInternal`.

### `2-conf-features.yml`

Configures Chocolatey settings and enables recommended features — `allowGlobalConfirmation`, `useRememberedArgumentsForUpgrades`, `exitOnRebootDetected`, timeout settings, and cache location.

### `bonus-1-legacy-windows.yml`

For Server 2012 R2 and older where .NET 4.8 isn't pre-installed. Chocolatey CLI v2+ requires it. Installs Chocolatey v1.4.5 first, gets .NET 4.8, reboots, then upgrades to latest.

### `bonus-2-ccm-client.yml`

Standalone CCM agent configuration for servers that already have Chocolatey. Useful when re-enrolling or when the FQDN or salts change.

## Credentials

| Environment variable | What it's for |
|---|---|
| `NEXUS_PASSWORD` | `chocouser` account password for Nexus (`ChocoUserPassword` in Key Vault) |
| `CCM_FQDN` | `chocolatey.allwayshype.com` |
| `CCM_CLIENT_SALT` | `ccmClientCommunicationSalt` from Key Vault |
| `CCM_SERVICE_SALT` | `ccmServiceCommunicationSalt` from Key Vault |
| `C4B_CERT` | Base64-encoded DER cert from Key Vault (`C4B-Azure-Certificate`) |

All stored as GitHub secrets, injected as environment variables by the workflow.

## GitHub Actions

The `chocolatey.yml` workflow is manual trigger only, which can be changed to atomatic based on your env workflow. You pick the playbook from a dropdown and `check_mode` defaults to true. Bootstrap is intentionally not wired to auto-run on push, it's a one-time operation per server.

The Az SSH extension gets installed on the runner so the Arc SSH proxy `pre_task` can tunnel through to `Srv02` and `Server2025`. The same bootstrap playbook runs against your Terraform VM over WinRM and your Hyper-V servers over SSH through the Azure Arc relay.
