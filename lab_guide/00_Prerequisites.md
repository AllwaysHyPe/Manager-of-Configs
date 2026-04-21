# Workshop Prerequisites

**Complete before the session**

This workshop is designed to remove setup friction. The primary environment is a pre-configured GitHub Codespace, so attendees can spend the session writing and shipping Terraform instead of installing tools.

## Technical Requirements Checklist

Use this checklist to verify the lab guidance will work exactly as written.

- Terraform CLI 1.14+
- Git 2.40+
- VS Code (latest stable) with GitHub Copilot and HashiCorp Terraform extensions
- GitHub account with Codespaces and Copilot access
- HCP Terraform is pre-configured for the workshop (no manual setup needed)

Why this matters:

- These versions support the commands and provider behaviors used in the lab.
- Attendees do not manage Azure RBAC/scoping in the core workshop path.
- HCP Terraform is pre-configured in the lab environment. Attendees do NOT need to create accounts, generate tokens, or configure workspaces.
- Core deployment trigger is `git push` to `main` in each attendee's learner copy (HCP Terraform runs automatically).

## What Attendees Need

### Required Before Arrival

- A GitHub account that can open GitHub Codespaces
- GitHub Copilot access in GitHub and VS Code
- Access to the workshop repository
- A browser that can sign in to GitHub

### Azure Access Model

Attendees do **not** need to configure Azure RBAC, role assignments, or deployment scope in the core workshop path.

Workshop assumption:

- The instructor/platform team preconfigures Azure access and deployment scope
- The attendee deploys by pushing to `main` in their learner copy

## Preferred Setup: GitHub Codespaces

This is the default workshop path.

### Codespaces Should Already Include

- Terraform CLI
- Git
- VS Code extensions needed for the workshop
- GitHub Copilot
- HashiCorp Terraform extension
- Any workshop sample files or starter content

### Attendee Verification Steps

After opening the Codespace, run:

```bash
terraform version
git --version
```

Then verify your learner copy is wired to the preconfigured HCP workflow and ready for push-to-main deployment.

## Local Machine Setup

Use local setup only if Codespaces is unavailable.

### Required Local Tools

- Terraform CLI 1.14+
- Git
- VS Code
- GitHub Copilot extension
- HashiCorp Terraform extension

### Local Verification

```powershell
terraform version
git --version
```

## Terraform MCP Server Setup

The Terraform MCP (Model Context Protocol) server enables GitHub Copilot to interact with HCP Terraform and the Terraform Registry, allowing you to look up module details, version information, and best practices directly from Copilot Chat.

### What You Need to Know

- The MCP server is a bridge between Copilot and HCP Terraform & the Terraform Registry
- It allows Copilot to: manage HCP Terraform workspaces, retrieve module and resource details from the Registry, find latest versions, and access Terraform documentation
- Configuration happens in VS Code via `.vscode/mcp.json`
- Docker is already installed in the Codespace (required by the MCP server)

### Installation and Configuration

The Terraform MCP server runs in a Docker container for consistency and portability.

**Step 1: Create the MCP configuration file**

In the repository root, create a `.vscode/mcp.json` file (or add to it if it already exists):

```json
{
  "servers": {
    "terraform": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e", "TFE_TOKEN=${input:tfe_token}",
        "-e", "TFE_ADDRESS=${input:tfe_address}",
        "hashicorp/terraform-mcp-server:0.5.1"
      ]
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "tfe_token",
      "description": "Terraform API Token",
      "password": true
    },
    {
      "type": "promptString",
      "id": "tfe_address",
      "description": "Terraform Address",
      "password": false
    }
  ]
}
```

**Step 2: Verify the configuration**

The MCP server will automatically start when Copilot first uses it, or you can start it manually from the editor window. No restart needed.

To confirm it's working:
1. Open Copilot Chat (`Ctrl+Shift+I`)
2. Type: `What inputs does the Azure storage account module accept?`
3. If Copilot responds with module details from the Terraform Registry, the MCP server is active

**Step 3: Test with a Registry Lookup**

In Copilot Chat, ask:
```
What's the latest version of the azurerm provider?
```

If successful, you'll see the current version information from the Terraform Registry.

### Troubleshooting

| Problem | Solution |
|---------|----------|
| "Docker not found" | Docker Desktop or Docker daemon is not running. The Codespace includes Docker—ensure the daemon is active. |
| "Terraform API Token missing" | MCP will prompt for `TFE_TOKEN` and `TFE_ADDRESS` on first use. Provide your HCP Terraform credentials. |
| Copilot doesn't respond to Terraform commands | Verify the `.vscode/mcp.json` file is in the repository root with correct syntax. Try asking Copilot again—the MCP server starts automatically on first use. |
| `.vscode/mcp.json` is ignored | Ensure the file is in the repository root (same level as `main.tf`), not in a subdirectory. |

### Local Machine Setup

If running locally instead of Codespaces:

1. Ensure Docker is installed and running: `docker --version`
2. Create `.vscode/mcp.json` in the repository root
3. Use the same configuration as above
4. When prompted, enter your HCP Terraform API Token and address (the MCP server starts automatically on first use)

## Instructor Checklist

### One Week Before

- Confirm the workshop repository opens correctly in GitHub Codespaces
- Confirm the Codespace image or dev container includes Terraform, Git, and VS Code extensions
- Verify each learner copy is connected to the preconfigured HCP workspace/workflow
- Verify workshop steps work end-to-end without attendees managing Azure RBAC/scoping
- Validate GitHub Copilot works in the Codespace
- **Verify `.vscode/mcp.json` is created and Terraform MCP server can be invoked from Copilot Chat**
- Validate the Terraform MCP server setup used in the workshop
- Validate the HCP Terraform demo flow used in the workshop

### Day Before

- Send attendees the repo link
- Send attendees a short "open Codespace and sign in" checklist
- Confirm attendees know they need GitHub and Azure access before the session starts
- Verify sample prompts, custom agent files, and skill files are present and current

### Right Before the Workshop

- Open the repo in a clean Codespace and verify the environment again
- Run `terraform version`
- Confirm a participant can push to `main` in their learner copy and see the expected HCP run trigger
- Have a backup attendee account or demo account ready
- Have a backup plan for attendees who cannot access Codespaces

## Fast Start for Attendees

Use this exact sequence at the top of the workshop:

```bash
# 1. Open the workshop repo in GitHub Codespaces

# 2. Verify the toolchain
terraform version
git --version

# 3. Confirm learner-copy deployment path
# push to main triggers the HCP run in your learner copy
```

## Common Problems

### HCP Run Not Triggered After Push

Confirm you pushed to `main` in your learner copy and that the repository-to-HCP wiring is active.

### Copilot Not Available

- Confirm you are signed into GitHub in VS Code
- Confirm your account has Copilot access
- Reload the VS Code window if the extension is installed but inactive

### Codespaces Is Not Available

Use the local machine setup path above. The workshop still works, but setup will take longer.

### Keyboard Shortcuts Not Working in Codespaces

Browser-based Codespaces may intercept shortcuts like Ctrl+K (typically used for line comments). If keyboard shortcuts for commenting or other editor functions don't work:

1. Try **Ctrl+/** instead of Ctrl+K
2. Or right-click the line and select **Toggle Line Comment**
3. If editing `.tf` files specifically, the Terraform extension must be active (watch for the extension loading in the output panel)
4. See Chapter 8 Troubleshooting for a permanent `.vscode/settings.json` workaround

## Ready Check

You are ready when all of these are true:

- You can open the workshop repo in GitHub Codespaces
- `terraform version` works
- You understand deployment is triggered by push to `main` in your learner copy
- GitHub Copilot is available in VS Code

If those four checks pass, the workshop can start.

---

**Next:** [Chapter 1: Introduction and Setup](./01_Introduction_and_Setup.md)
