# Chapter 5: Copilot and MCP
**Duration:** 25-30 minutes  
**Objective:** Use GitHub Copilot with Terraform MCP Server to write infrastructure code at high velocity

---

## 📍 Learning Outcomes

By the end of this Chapter, participants will:
- [ ] Understand what MCP (Model Context Protocol) is
- [ ] Use Copilot Chat to author Terraform code
- [ ] Use Terraform MCP Server to look up module details, versions, and best practices
- [ ] See how AI speeds up IaC authoring
- [ ] Write reusable patterns with Copilot

---

## ⏱️ Timing Breakdown
- **What is MCP? (ultra-quick):** 2 min
- **Copilot for Terraform demo:** 8-10 min
- **Live hands-on:** 10-12 min
- **Terraform MCP server validation:** 3-5 min

## Why This Chapter Matters

Participants have now deployed from the repository root using the push-to-main-triggered run model in their learner copies, and used AVM patterns for safer defaults. This chapter shows how to accelerate authoring while keeping validation in the loop so speed does not reduce quality.

## Companion Files For This Chapter

- Use [ref-resources.md](./reference/ref-resources.md) as the prompt pack for the live Copilot demos.
- Show `.github/copilot-instructions.md` so attendees can see how the repo carries shared Copilot guidance.
- Point to `.github/agents/terraform-azure.agent.md` as the bridge into the next custom-agent Chapter.

---

## 🎤 Speaker Notes

### **What is MCP? (2 min - Ultra-Compressed)**

**One sentence:**
> "MCP connects AI tools (like Copilot) to domain tools (like HCP Terraform and the Terraform Registry). So Copilot can retrieve live module data and best practices, not just suggest them."

**Three examples:**
1. You ask Copilot: "What inputs does the AVM storage account module accept?"
2. Copilot queries the Terraform Registry and shows you the actual module documentation
3. You get definitive answers backed by live registry data, not guesses

**That's it.** No deep theory. Move on.

**Say:**
> "The result: Copilot goes from 'I think the module works like this' to 'Here's what the module actually does, straight from the Terraform Registry.'"

---

## 🎬 Live Demo: Use Copilot to Write Terraform

### **Scenario: Add a Database to Your Project**

Imagine we want to add an Azure SQL Database to our infrastructure. Instead of writing it from scratch, we'll use Copilot.

### **Step 1: Open Copilot Chat (1 min)**

In VS Code (your Codespace):
1. Click the **Copilot Chat icon** (left sidebar, looks like a speech bubble)
2. Or press `Ctrl+Shift+I` (Windows) / `Cmd+Shift+I` (Mac)

**Copilot Chat is now ready.**

### **Step 2: Ask Copilot to Generate Terraform (2-3 min)**

**In Copilot Chat, type:**

```
I'm using Terraform with Azure. I want to add a SQL Database to my 
infrastructure. Give me Terraform code using the Azure Verified Module 
for SQL Server. Use variables for server name, database name, and admin password.
```

**Click Send.**

**What Copilot does:**
1. Reads your message
2. Understands you want Terraform + Azure SQL + AVM
3. Generates code with the right module, variables, outputs

**Expected output:** Copilot gives you ~40-50 lines of ready-to-use code.

### **Step 3: Review the Code (1-2 min)**

Copilot outputs:
```hcl
module "sql_database" {
  source = "Azure/avm-res-sql-server/azurerm"
  version = "0.2.0"

  location            = var.location
  resource_group_name = var.resource_group_name
  server_name         = var.sql_server_name
  administrator_login = var.admin_username
  # ... more config
}
```

**Talk through it:**
- "See? AVM for SQL. Best practices built-in."
- "It's asking for inputs via variables—exactly what we want."
- "No boilerplate. Just the essential config."

### **Step 4: Copy Code into Your Project (1 min)**

Click the **copy button** in Copilot's response.

Paste into `main.tf`.

### **Step 5: Ask Copilot to Generate Variables (1-2 min)**

**In Copilot Chat, type:**

```
Now write the variables for this SQL module. Include descriptions 
and sensible defaults where possible.
```

Copilot generates `variables.tf` entries. Copy them into `variables.tf`.

### **Step 6: Validate with Terraform (2-3 min)**

Now the real magic. In terminal:

```bash
terraform validate
```

**Two outcomes:**

**A) "Success!" (most likely)**
> "Terraform says your code is syntactically correct. No typos, no missing pieces."

**B) "Error: ..." (less likely)**
> "Terraform found an issue. Most common: wrong variable name, missing required input."

**If error:**

**In Copilot Chat:**
```
I got this Terraform error:
[paste the error]

Can you fix the code?
```

Copilot reads the error and provides a corrected version. Copy it back in.

---

## 🚀 Copy-Paste Prompts You Can Reuse

These prompts work in Copilot Chat for Terraform generation:

### **Prompt 1: Generate a New Resource**
```
I want to add a {RESOURCE_TYPE} to my Terraform project.
Use the Azure Verified Module if available.
Make it production-ready with encryption and monitoring enabled.
Generate the code with variables for {KEY_PARAMETERS}.
```

### **Prompt 2: Convert Portal Config to Terraform**
```
I manually created a {RESOURCE_TYPE} in Azure. Here's its config:
[paste properties from portal]

Write Terraform code to recreate this resource using an AVM.
```

### **Prompt 3: Add Security Best Practices**
```
Here's my Terraform code:
[paste code]

What security best practices am I missing?
How do I improve it? Rewrite with improvements.
```

### **Prompt 4: Explain Error**
```
I got this Terraform error:
[paste error]

What went wrong? How do I fix it?
```

---

## 🎯 Terraform MCP Server Validation (3-5 min)**

### Before You Start: Is the MCP Server Installed?

The Terraform MCP server must be configured before you can use it in Copilot Chat. If you haven't done this yet, follow the setup steps below.

### MCP Server Setup (First Time Only)

**What is the Terraform MCP Server?**

It's a bridge that lets Copilot actually RUN Terraform commands and retrieve live module metadata. Not just suggest—actually check resources, validate syntax, plan changes, and explain outcomes.

**Step 1: Create the MCP Configuration**

In the repository root, create a new file called `.vscode/mcp.json`:

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

This configuration:
- Runs the Terraform MCP server in a Docker container for consistency
- Prompts for your HCP Terraform API Token and address on first use
- Securely passes credentials as environment variables to the MCP server

**Where to create it:**
- Locate the root of your repository (where `main.tf` is)
- Create a new folder called `.vscode` (if it doesn't exist)
- Inside `.vscode`, create a file called `mcp.json`
- Paste the JSON above into that file
- Save it

**Step 2: MCP Server Starts Automatically**

The MCP server starts automatically when Copilot first uses it, or you can start it manually from the editor window. No restart needed.

**Step 3: Verify It's Running**

Open Copilot Chat (`Ctrl+Shift+I`) and type:

```
What inputs and outputs does the Azure storage account AVM provide?
```

**Expected response:**
- Copilot connects to the Terraform Registry and retrieves the module documentation
- You see the actual inputs, outputs, and resources created by the module

If Copilot says "I can't run that command," verify the `.vscode/mcp.json` file is in the repository root with correct syntax. Try asking Copilot again—the MCP server starts automatically on first use.

---

### Demo: See the MCP Difference in Action (5 min)

This is the "aha moment" where attendees see MCP's real power.

#### **The Setup: Terraform Files in Your Repo**

You have `.tf` files in your project. Let's use MCP to understand them better than Copilot could without MCP.

#### **Without MCP (Static File Analysis)**

If Copilot only had the HCL files in your workspace, it would say something like:

```
"I see you have a storage account module, but I can't tell you:
- What inputs it actually accepts (I'd have to guess)
- What resources it creates (I'd have to read the module source code)
- Whether your config will work (I can't validate against the provider)"
```

#### **With MCP (Four Specific Capabilities)**

Now ask Copilot:

**Prompt:**
```
What inputs, outputs, and resources does the Azure storage account 
AVM module provide? Also, what are the latest versions of azurerm and 
this module? Show me best practices for configuring Azure storage with Terraform.
```

**Copilot (with MCP) responds with:**
1. ✅ **Check Module Resources & Properties:** Looks up the Azure storage account module in the Terraform registry and retrieves its actual inputs, outputs, and the resources it creates (e.g., storage account, network rules, encryption)
2. ✅ **Version Lookup:** Retrieves the latest available versions of modules and providers from the Terraform Registry
3. 📋 **HCP Terraform Integration:** Can interact with HCP Terraform workspaces to check runs and state (if credentials are configured)
4. 📚 **Best Practices:** Retrieves Terraform documentation and recommended configurations from the Terraform documentation

**The difference:** Copilot went from "I think..." to "I verified by actually checking your code and the live module definitions."

#### **Try It Now (Live Demo)**

1. Open your Terraform files in the workspace
2. In Copilot Chat, paste this prompt:

```
I'm using the Azure storage account AVM. Can you:
1. Show me what inputs and outputs this module provides
2. Tell me the latest available versions of the azurerm provider and this module
3. Explain best practices for configuring storage accounts in Terraform
4. Describe what resources this module creates
```

3. Watch Copilot connect to MCP and:
   - **Check module resources & properties** — pulls the actual module definition from the Terraform registry
   - **Get module inputs & outputs** — queries the registry for detailed parameter information
   - **Find current versions** — looks up the latest stable version of modules and providers
   - **Show documentation** — retrieves best practices and usage examples from the registry
4. Compare what MCP shows you (live module data, documentation, version info) vs. what static file reading could show (guesses and assumptions)

---

### Troubleshooting MCP

| Problem | What's Happening | Fix |
|---------|------------------|-----|
| "I can't look up module data" | MCP server hasn't started yet | Verify `.vscode/mcp.json` is in the repository root with correct syntax. Try asking Copilot again—the MCP server starts automatically on first use. |
| "Docker not found" | Docker daemon is not running or Docker is not installed | Ensure Docker Desktop is running. Codespaces includes Docker; if missing, rebuild your Codespace. |
| Prompt for credentials never appears | HCP Terraform credentials weren't configured | Try asking Copilot to look up a Terraform module—it will prompt for Token and Address if needed for HCP queries. |
| `.vscode/mcp.json` appears but Copilot ignores it | File isn't in the right location | Make sure `.vscode/mcp.json` is in the **repository root** (same folder level as `main.tf`). |
| Registry queries are slow | Network latency or Registry service response time | Queries to the Terraform Registry depend on network speed. Retry if a single query is slow. |

---

## 🎓 The Velocity Play

**Without Copilot + MCP:**
1. Write Terraform code (20-30 min)
2. Test locally (5 min)
3. Read errors (10 min)
4. Fix and re-test (15 min)
5. **Total: ~50+ minutes**

**With Copilot + MCP:**
1. Describe what you want in chat (2-3 min)
2. Copilot writes code (instant)
3. Validate with MCP (2 min)
4. Deploy (5 min)
5. **Total: ~10-12 minutes**

**We literally ship 5x faster.**

---

## 🏁 Transition to Chapter 6

**Closing statement:**

```
"Copilot + MCP just turned writing Terraform from a chore into a 
conversation. You describe what you want. Copilot writes the code. 
MCP queries the Registry for best practices and details. You review and deploy.

Next up: we'll capture what we've learned as reusable Skills — 
institutional knowledge your whole team can use and build on."
```

---

## ❓ Likely Q&A

**Q: "Does Copilot always give correct Terraform?"**  
A: "Mostly, yes. Sometimes it generates syntactically correct but semantically wrong code. That's why we validate. MCP catches those."

**Q: "What if I'm not comfortable with AI-generated code?"**  
A: "Read it carefully. Test it. Modify it. Copilot is an assistant, not an oracle. Use it as a starting point."

**Q: "Can Copilot write complex infrastructure?"**  
A: "Yes, but you might need to give it more context. Break it into smaller pieces and ask Copilot for each one."

**Q: "Is my code sent to OpenAI when I use Copilot?"**  
A: "GitHub Copilot uses OpenAI's models, but with enterprise privacy controls. Microsoft doesn't train on your code without permission."

---

## 💡 Pro Tips for Delivery

1. **Have the Chat visible.** Show participants where to click.
2. **Use a real example.** Not a toy one. Show productivity.
3. **Don't pretend it's perfect.** "Copilot usually gets it right, but always validate."
4. **Keyboard shortcut matters.** `Ctrl+Shift+I` is faster than clicking.
5. **Mention Ctrl+/:** "If Copilot Chat doesn't suggest something, you can also press Ctrl+/ to ask it inline about code."

---

**Next:** [Chapter 6: Skills and Knowledge](./06_Skills_and_Knowledge.md)
