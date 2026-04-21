# Chapter 7: Copilot Customization — Instructions and Custom Agents
**Duration:** 30-35 minutes *(beyond the 140-165-minute core path)*

> ⏱️ **Stretch Goal** — This chapter is optional. Complete it if you have time remaining after Chapter 6. If not, proceed directly to [Chapter 8: Wrap Up](./08_Wrap_Up.md).

---

## 📍 Learning Outcomes

By the end of this chapter, participants will be able to:
- [ ] Explain the three ways to customize Copilot's behavior in VS Code: repo-wide instructions, scoped instructions, and custom agents
- [ ] Distinguish between *passive* instruction files (always-on context injection) and *active* agent files (invokable modes in the Chat panel)
- [ ] Read and understand `.github/copilot-instructions.md` and explain when it applies
- [ ] Describe how `.github/instructions/*.instructions.md` files scope context to specific file patterns
- [ ] Read and understand an `.agent.md` file and its frontmatter fields
- [ ] Explain what the `tools` field controls and what values are available
- [ ] Create a custom agent file in `.github/agents/` for this workshop's Terraform workflows
- [ ] Invoke their custom agent via the VS Code Copilot Chat agent picker
- [ ] Confirm the agent appears and behaves as configured

---

## ⏱️ Timing Breakdown
- **Concepts: the three customization file types:** 6-7 min
- **Tour of the repo's existing files:** 4-5 min
- **Anatomy of an `.agent.md` file:** 4-5 min
- **Hands-on: create the TerraformSecurityReviewer agent:** 8-10 min
- **Live test and debrief:** 4-5 min
- **Q&A:** 1-2 min

---

## Companion Files For This Chapter

- `.github/copilot-instructions.md` — the repo's always-on instructions file (live example of passive context)
- `.github/agents/terraform-azure.agent.md` — the workshop's live example custom agent
- The hands-on exercise has attendees create their own agent in `.github/agents/`

> 🗂️ **Workshop rule:** For this workshop, create all agent files in `.github/agents/`. This keeps them team-shared and part of the repository.

---

## 🎤 Speaker Notes & Slides

### **Opening Hook (1 min)**

```
"You've built reusable skills in Chapter 6.
Now let's talk about the broader picture: how do you make Copilot
*always* aware of your conventions — not just when you tell it?

There are three tools for this in VS Code. Two are passive — they inject
context automatically. One is active — it's a named AI mode you switch into.

This repo already uses all three. Let's look at what's here, understand why
each one exists, and then build our own custom agent."
```

---

## **Part 1: The Three Ways to Customize Copilot (6-7 min)**

### **The Problem**

Every Copilot Chat session starts fresh. Without customization:
- Copilot doesn't know your naming conventions
- It doesn't know you prefer Azure Verified Modules
- It doesn't know you're constrained to resource-group scope
- It doesn't know to run `terraform validate` before `terraform apply`

You re-explain the context every session. The three customization files solve this — each in a different way.

---

### **File Type 1: `.github/copilot-instructions.md` — Repo-Wide, Always-On**

This file injects instructions into **every** Copilot Chat conversation in the repository. It's passive — Copilot reads it automatically, no action required from the user.

**When it applies:** Every chat session opened in this repo, for every user, for every file type.

**What it's for:** Project-wide rules that always apply — architecture decisions, coding conventions, security constraints.

**This repo's example:**

```
.github/copilot-instructions.md
```

Open it and look — it tells Copilot to prefer Azure Verified Modules, run `terraform fmt` before `apply`, use resource-group scope only, and never hardcode secrets. Every time anyone opens Copilot Chat in this repo, those rules are already loaded.

> 📌 **Key point:** This file creates no named agent. It is not invokable. It simply injects context into every conversation, silently, in the background.

---

### **File Type 2: `.github/instructions/*.instructions.md` — Scoped, Pattern-Based**

These files also inject context automatically, but only when the files matching a glob pattern are open or active in the editor. You define the scope in the file's YAML frontmatter.

**Example frontmatter:**

```yaml
---
applyTo: "**/*.tf"
---
Always prefer Azure Verified Modules. Never hardcode secrets or tenant IDs.
```

With this file in `.github/instructions/terraform.instructions.md`, Copilot automatically adds the scoped instructions whenever a `.tf` file is the active context — and ignores them otherwise.

**When to use this vs `copilot-instructions.md`:**

| | `copilot-instructions.md` | `instructions/*.instructions.md` |
|--|--|--|
| Scope | Always applies | Only when matching files are open |
| Use for | Project-wide rules | Language/technology-specific rules |
| Invokable by user? | No | No |

> 📌 **Key point:** Like `copilot-instructions.md`, these files are **passive**. They inject context automatically based on file patterns. They do not create named agents or appear in any picker.

---

### **File Type 3: `.github/agents/*.agent.md` — Active, Invokable Agents**

This is the big one. An `.agent.md` file defines a **named Copilot Chat mode** — a specialized AI persona that the user explicitly selects in the Chat panel.

**How it works:**
1. You create `.github/agents/my-agent.agent.md`
2. VS Code detects the file automatically
3. The agent appears in the **agent picker** in the Copilot Chat panel
4. The user opens Copilot Chat and clicks the agent selector (`@` or the mode dropdown) to pick it

**How to invoke:** Open Copilot Chat (`Ctrl+Alt+I`), then click the agent selector at the top of the panel. Your agent appears there by name. Select it — all subsequent messages in that session run through the agent's system prompt.

> 📌 **Key point:** This is the only customization type the user actively selects. Instructions files are passive context; agent files are invokable modes.

> 📖 **Reference:** [VS Code Docs — Custom Chat Modes](https://code.visualstudio.com/docs/copilot/chat/chat-modes)

---

### **Summary: Passive vs Active**

| File | Mechanism | Invoked by user? | Appears in Chat UI as |
|------|-----------|------------------|-----------------------|
| `.github/copilot-instructions.md` | Auto-injected every session | No | Invisible background context |
| `.github/instructions/*.instructions.md` | Auto-injected when file pattern matches | No | Invisible background context |
| `.github/agents/*.agent.md` | User selects from Chat agent picker | **Yes** | Named mode in agent selector |

---

## **Part 2: What Custom Agents Are NOT**

Before building one, clear up the most common misconception.

Custom agents are **not** `@`-prefixed chat participants like `@workspace`, `@vscode`, or `@terminal`. Those are built-in VS Code extensions. You type `@workspace` inline in the chat input and it responds as a participant.

**Custom agent modes work differently:** you select them from the **agent picker** at the top of the Copilot Chat panel. Once selected, the agent mode is active for the whole session. You do **not** type `@TerraformArchitect` or any `@mention` to invoke your custom agent.

---

## **Part 3: Anatomy of an `.agent.md` File (4-5 min)**

### **The Format**

An `.agent.md` file has YAML frontmatter followed by a system prompt in markdown. Here is the workshop's existing Terraform agent:

```yaml
---
name: Terraform Azure Architect
description: "Use when designing, reviewing, or refactoring Azure Terraform with Azure Verified Modules, HCP Terraform, GitHub Copilot, or resource-group-scoped deployment workflows."
tools: [read, edit, search, execute]
argument-hint: "Describe the Azure resource or Terraform change you want help with."
user-invocable: true
---
```

### **Frontmatter Field Reference**

| Field | What It Does |
|-------|-------------|
| `name` | The display name that appears in the agent picker |
| `description` | Shown in the selector; helps users understand when to use it |
| `tools` | Which Copilot tools the agent can use (see below) |
| `argument-hint` | Placeholder text shown in the chat input when the agent is selected |
| `user-invocable` | `true` makes it appear in the agent picker for users |

### **The `tools` Field**

| Value | What It Allows |
|-------|---------------|
| `read` | Read files in the workspace |
| `edit` | Create and edit files |
| `search` | Search the codebase and web |
| `execute` | Run terminal commands |

> ⚠️ **Important:** Only include the tools your agent actually needs. A read-only reviewer needs `[read, search]`. An agent that scaffolds files needs `[read, edit, search]`. Add `execute` only if you need terminal commands (like running `terraform validate`). Fewer tools = less risk.

### **Optional: Introduce Skills as Agent Companions (2–3 min extra)**

**💡 Pro Tip for Live Delivery**

If engagement is high and time allows, plant the seed that agents can **reference skills**. This bridges Chapter 6 (Skills & Knowledge) with Chapter 7 (Agents) and shows a real-world modularity pattern — especially valuable if attendees plan to grow their custom agent library.

**Quick script:**

```
"You built skills in Chapter 6 — reusable prompt files with domain expertise.
Agents can reference those skills, and frankly, the best agents do.

For example, the security reviewer agent you're about to create doesn't need
to embed every security check into its system prompt.

Instead, it can reference a 'Terraform Security Checklist' skill —
a separate file documenting what to check, why it matters, and how to fix it.

The agent stays lean. The skill is reusable. If you create a compliance auditor
agent next month, it uses the same checklist. You update the checklist once,
both agents benefit.

That's how you build a scalable, maintainable custom agent library."
```

**Where skills live:**
- `.github/copilot/skills/` — default location (team-shared, part of the repo)
- `.github/agents/` — alongside agents (less preferred; mixes concerns)
- Any path, so long as the agent's system prompt includes a reference like:  
  `You have access to the Terraform Security Checklist skill at .github/copilot/skills/terraform-security-checklist.md.`

**No need to create a full skill during this chapter** — just plant the idea. Curious attendees will experiment afterward, and you've given them the pattern.

---

### **Below the Frontmatter**

Everything below the closing `---` is the **system prompt** — the persistent instructions Copilot follows whenever this agent mode is active. This is where you define:
- The agent's role and expertise
- Constraints (what it should never do)
- Preferred patterns and modules
- Output format expectations

---

## **Part 4: Walk Through the Workshop's Existing Agent (3-4 min)**

Open `.github/agents/terraform-azure.agent.md` in the editor. Walk through it:

1. **`name: Terraform Azure Architect`** — this is the label that appears in the agent picker
2. **`tools: [read, edit, search, execute]`** — full capability; needs `execute` for running validation commands
3. **`user-invocable: true`** — makes it appear in the agent picker
4. **The system prompt** — defines goals (prefer AVM), constraints (no subscription-level permissions, no hardcoded secrets), approach (inspect before changing, explain everything), and output format

> **Live demo:** Open the Copilot Chat panel and click the agent selector. Point to "Terraform Azure Architect" in the list — show how it appears there, not as a typed `@mention`. Select it and ask: `What patterns do you follow for this repository?` — it should reflect the system prompt.

---

## **Part 5: Hands-On — Create Your Own Agent (10-12 min)**

You will create a focused **security review** agent — an agent whose sole job is to look at Terraform code and flag security issues.

> 🗂️ **Workshop rule:** Create this file in `.github/agents/`. That's the team-shared location. VS Code will detect it automatically.

### **Step 1 — Create the agent file**

In the Explorer panel (or terminal), create:

```
.github/agents/terraform-security-reviewer.agent.md
```

### **Step 2 — Write the frontmatter**

Open the file and add:

```yaml
---
name: Terraform Security Reviewer
description: "Reviews Terraform files for security issues: hardcoded secrets, open NSGs, public IPs, missing tags, and insecure defaults."
tools: [read, search, terraform/search_modules, terraform/get_module_details]
argument-hint: "Paste or open the Terraform file you want reviewed."
user-invocable: true
---
```

> **Note:** This agent includes `read` and `search` for code analysis, plus `terraform/search_modules` and `terraform/get_module_details` to look up module information when verifying module security. It does not write or run commands. Keep the `tools` list minimal.

### **Step 3 — Write the system prompt**

Below the closing `---`, add:

```markdown
# Terraform Security Reviewer

You are a focused Azure Terraform security reviewer. Your only job is to read Terraform files and identify security issues.

## What You Check

1. **Hardcoded credentials** — secrets, passwords, tokens, or keys in `.tf` files or variable defaults
2. **Overly permissive NSG rules** — any rule opening ports to `0.0.0.0/0` or `::/0`, especially management ports (22, 3389, 5985)
3. **Public IP exposure** — resources assigned public IPs that do not explicitly need them
4. **Missing required tags** — resources lacking `environment` and `workshop` tags
5. **Admin features enabled** — `admin_enabled = true` on container registries, weak auth settings
6. **Insecure defaults** — `public_network_access_enabled = true`, unencrypted storage, HTTP endpoints

## How You Respond

For every file you review:
- State which file you are reviewing
- List each issue found with: the exact line(s), the risk, and a corrected code snippet
- If nothing is found, say so explicitly with a brief summary of what was checked

## Constraints

- Do not suggest changes to logic, naming, or formatting unless they are directly related to a security issue
- Do not run commands — you read and analyze only
- Do not make assumptions about intent; report what you observe
```

### **Step 4 — Save and invoke the agent**

1. Save the file
2. Open VS Code Copilot Chat (`Ctrl+Alt+I`)
3. Click the **agent selector** at the top of the Chat panel (the `@` button or mode dropdown)
4. Confirm **"Terraform Security Reviewer"** appears in the list
5. Select it
6. Open `main.tf` in the editor and type: `Review this file`

Expected: The agent responds as the security reviewer, checking the file against its checklist and reporting findings.

> **Debrief point:** The agent required zero code. It's a markdown file. The system prompt IS the agent. Edit the file and save — VS Code picks up the change immediately, no restart needed.

---

## **Part 6: How the Three Files Work Together (2 min)**

Now you can see how all three customization types stack:

1. **`.github/copilot-instructions.md`** — always-on; loads for every session, every user, every file. Establishes the baseline project context.
2. **`.github/instructions/*.instructions.md`** — loads automatically when matching files are open; adds technology-specific context on top.
3. **`.github/agents/*.agent.md`** — user selects it from the Chat panel; takes over with a specialized persona and restricted toolset.

When you're in the Terraform Security Reviewer agent, _all three layers are active at once_: the repo-wide instructions, any matching scoped instructions, plus the agent's own system prompt.

---

## **Part 6a: Skills as Agent Companions (Optional; 2–3 min if time allows)**

**When to deliver:** If the group is engaged and questions are light, plant this seed. It's not required for core learning, but it opens eyes to real-world scalability.

**Setup:** "We've now built an agent. Let's talk about how to make it even more powerful — and reusable — by pairing it with a **skill**."

### **The Pattern**

Recap from Chapter 6: a **skill** is a reusable prompt file that documents domain expertise — patterns, checklists, best practices.

An **agent** can reference a skill, pulling in that expertise without bloating its own system prompt.

**Example:** The Terraform Security Reviewer agent could reference a `.github/copilot/skills/terraform-security-checklist.md` skill file.

- **Skill file** — defines the six security categories to check, the risk of each, and the correct fixes
- **Agent system prompt** — stays lean: "Use the terraform-security-checklist skill as your authoritative source"

**Benefits:**
- Agent is 15 lines, not 60
- Checklist is reusable (a compliance auditor agent, a team guide, etc. can use it too)
- When the team's security standards evolve, you edit the skill file once

### **Where Skills Live**

- `.github/copilot/skills/` — default, team-shared (recommended)
- `.github/agents/` — alongside agents (okay, but mixes concerns)
- Any path, documented in the agent's system prompt

### **How an Agent References a Skill**

In the agent's system prompt:

```markdown
You have access to the Terraform Security Checklist skill at .github/copilot/skills/terraform-security-checklist.md.
Use this skill as your authoritative source for what to check and how to report findings.
```

Copilot loads the skill and treats it as part of the agent's knowledge.

### **A Full Example Skill (For Reference)**

If you want to show attendees what this looks like, here's a compact security checklist skill:

```markdown
# Terraform Security Checklist Skill

This skill defines security checks applied by the Terraform Security Reviewer agent and other auditing tools.

## Categories & Fixes

### 1. Hardcoded Credentials
**Risk:** Secrets in version control expose infrastructure to attackers.  
**Fix:** Use Azure Key Vault, GitHub Secrets, or environment variables. Never hardcode secrets.

### 2. Overly Permissive Network Access
**Risk:** NSG rules open to 0.0.0.0/0 on management ports (22, 3389, 5985, etc.) invite brute-force attacks.  
**Fix:** Restrict source IPs; use bastion hosts or private endpoints.

### 3. Public IP Exposure
**Risk:** Unnecessary public IPs expand the attack surface.  
**Fix:** Use private IPs; route through NAT, load balancers, or app gateways.

### 4. Missing Required Tags
**Risk:** Untagged resources are hard to audit, bill, and manage.  
**Fix:** Tag all resources with environment and workshop tags (or per your standard).

### 5. Insecure Service Defaults
**Risk:** admin_enabled=true, HTTP endpoints, unencrypted storage go unnoticed.  
**Fix:** Explicitly set secure defaults (admin_enabled=false, https_only=true).

### 6. Missing Encryption or Audit Logging
**Risk:** Data breaches and compliance violations go undetected.  
**Fix:** Enable encryption at rest and in transit; enable diagnostic logging.
```

**Talking point:** "See how focused this is? It's not a novel. It's a checklist. The agent reads it, applies it to the code, and reports findings. If you want a compliance auditor agent or a documentation generator next month, they can reference the same skill. You update the skill once, every tool benefits."

---



```bash
git add .github/agents/terraform-security-reviewer.agent.md
git commit -m "feat: add Terraform Security Reviewer custom agent mode"
git push origin main
```

Every team member who pulls this repository can now select this agent from their Copilot Chat agent picker.

---

## 🏁 Transition to Chapter 8

**Closing statement:**

```
"You've now built a custom AI mode that lives in your repository.

It's a markdown file — two dozen lines.
VS Code picks it up automatically.
Every team member gets it when they pull.

You've also seen how it layers on top of the repo-wide instructions
and scoped instructions — context that was already there, silently,
from the moment you cloned this repo.

That's the last hands-on chapter. Let's wrap up and talk about where to go from here."
```

---

## 🎯 Quick Verification Checklist

Before moving to Chapter 8, confirm:

- [ ] Explained the difference between passive instruction files and active agent files
- [ ] Opened `.github/copilot-instructions.md` and explained it loads for every session automatically
- [ ] Explained `.github/instructions/*.instructions.md` for scoped, pattern-based context injection
- [ ] Opened `.github/agents/terraform-azure.agent.md` and explained each frontmatter field
- [ ] Verified the `tools: [read, edit, search, execute]` values match the actual file
- [ ] Demonstrated the Terraform Azure Architect agent in the Chat panel agent picker (not via typed `@mention`)
- [ ] Created `.github/agents/terraform-security-reviewer.agent.md` with `tools: [read, search]`
- [ ] Confirmed the new agent appears in the Copilot Chat agent picker
- [ ] Tested the security reviewer against a Terraform file
- [ ] Committed and pushed

---

## ❓ Likely Q&A

**Q: "Can I call the agent with `@TerraformArchitect` like a chat participant?"**  
A: "No — custom agent modes are not `@`-mention chat participants. You select them from the **agent picker** at the top of the Copilot Chat panel. The `@workspace`, `@vscode`, and `@terminal` participants are built-in VS Code extensions — a completely different mechanism. Your agent appears in the picker dropdown, not as a typed `@` command."

**Q: "What's the difference between `copilot-instructions.md` and an agent?"**  
A: "`copilot-instructions.md` is passive — it injects context into every conversation automatically, with no action from the user, no special mode, no persona change. An agent is active — the user explicitly selects it from the Chat panel to switch into a specialized mode. Use instructions for always-on project context; use agents for focused, task-specific personas."

**Q: "When would I use `.github/instructions/*.instructions.md` instead of `copilot-instructions.md`?"**  
A: "When the context is only relevant for specific file types. For example, a `.instructions.md` with `applyTo: '**/*.tf'` only adds Terraform guidance when a `.tf` file is active — it won't clutter conversations about your PowerShell scripts or YAML files. Use `copilot-instructions.md` for rules that apply everywhere; use scoped instructions for rules that only make sense for certain technologies."

**Q: "What tools should I give my agent?"**  
A: "Only what it needs. A read-only reviewer needs `[read, search]`. An agent that scaffolds files needs `[read, edit, search]`. Add `execute` only if the agent must run terminal commands like `terraform validate`. More tools = more attack surface if the agent goes off-script."

**Q: "Where does the `.agent.md` file go?"**  
A: "For team-shared agents: `.github/agents/`. For personal agents not shared with the team: `~/.config/github-copilot/agents/` (user-level, not in the repo). For this workshop, always use `.github/agents/` so the agent is part of the repo."

**Q: "Does the agent remember context between sessions?"**  
A: "No. The system prompt is always-on within a session, but the conversation history resets when you close and reopen Chat. The repo-wide `copilot-instructions.md` supplements this — it adds project context automatically every session, so some persistent context is always there even without the agent active."

**Q: "Can I have multiple agents?"**  
A: "Yes. Each `.agent.md` file in `.github/agents/` becomes a separate entry in the agent picker. You could have a design agent, a security reviewer, a cost estimator, etc. The picker lists them all."

**Q: "How do agents work with skills?"**  
A: "An agent can reference a skill file in its system prompt to pull in domain expertise without bloating its own instructions. For example, the security reviewer agent references a `.github/copilot/skills/terraform-security-checklist.md` skill file that defines what to check and how to report findings. The benefit: the agent stays lean, the skill is reusable across multiple agents, and you update the checklist once — all agents that reference it benefit. It's a scalable pattern for building a library of custom agents."

---

## 💡 Pro Tips for Delivery

1. **Show the agent picker live.** Open the Copilot Chat panel and point to the agent selector at the top. Many attendees haven't noticed it. The moment they see their agent name appear there, it clicks.
2. **Open `copilot-instructions.md` first.** Walk through it before touching agents — it grounds the "passive vs active" distinction in something concrete and already in the repo.
3. **Contrast with `@workspace`.** Explicitly say "this is NOT the `@workspace` command" — the confusion is common and worth pre-empting.
4. **Keep the demo agent small.** A 20-line system prompt with three clear constraints is more convincing than a 200-line novel. Attendees will replicate what looks manageable.
5. **Edit live.** Add a new rule to the system prompt, save, switch agents and switch back. Show that the update is immediate.
6. **Connect to Chapter 6.** The skills from Ch06 are reference patterns agents can be told to use. A well-structured team has both: skills for documented patterns, agents for specialized AI behavior.

---

**Next:** [Chapter 8: Wrap-Up](./08_Wrap_Up.md)
