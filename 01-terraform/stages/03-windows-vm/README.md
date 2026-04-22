# 03-windows-vm

Full VM stack. Terraform provisions the infrastructure and sets the tags that
drive everything downstream. Once this apply completes Terraform's job is done.

## What this deploys

- Resource group named `mgrcnfgs-{random}`
- Storage account via AVM (carries forward from stage 02)
- Virtual network and subnet
- Public IP and NSG allowing inbound HTTP on port 80
- Network interface
- Windows Server 2022 VM (Standard_D2_v4)
- CustomScriptExtension that installs IIS and writes an index page

## Setup

```bash
cp backend.azurerm.tfbackend.example backend.azurerm.tfbackend
cp terraform.tfvars.example terraform.tfvars
```

## Commands

```bash
terraform init "-backend-config=backend.azurerm.tfbackend"
terraform plan "-out=tfplan"
terraform apply tfplan
```

VM provisioning takes 5-10 minutes. The IIS extension adds another 3-5 minutes.

## Verify

```bash
terraform output vm_public_ip
terraform output avm_storage_account_name
```

Open `http://{public_ip}` in a browser. If the page does not load immediately
wait a couple of minutes for IIS to finish initializing.

## Notes

The NSG allows inbound HTTP from any source. This is intentional for the demo.
In production restrict `source_address_prefix` to known ranges and terminate
HTTPS at a load balancer or Application Gateway.

The VM tags `role=webserver` and `choco_agent=true` are what Ansible's dynamic
inventory uses to target this server. Any server with these tags gets picked up
automatically on the next Ansible run without any manual registration.

## Tear down

```bash
terraform destroy -auto-approve
```