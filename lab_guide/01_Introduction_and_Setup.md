# Chapter 1: Introduction and Setup
**Duration:** 15 minutes  
**Objective:** Access your pre-created workshop repository, open it in GitHub Codespaces (the preconfigured lab environment), and prepare for push-based deployment

---

## Learning Outcomes

By the end of this chapter, participants will:
- [ ] Have accessed your pre-created workshop repository in the `a-demo-organization` GitHub organization
- [ ] Have opened the repository in GitHub Codespaces (the pre-configured lab environment)
- [ ] Understand the push-to-deploy model used in this workshop
- [ ] Be ready for Terraform fundamentals and hands-on implementation

---

## Timing Breakdown
- Intro Step 1 (find your pre-created repo): 5 min
- Intro Step 2 (open Codespace): 5 min
- Environment verification: 3 min
- Flow preview: 2 min

## Companion Files For This Chapter

- Use [00_Prerequisites.md](./00_Prerequisites.md) for troubleshooting checks.
- Use [reference/ref-resources.md](./reference/ref-resources.md) for reusable commands.
- Use [reference/ref-repo-template-guide.md](./reference/ref-repo-template-guide.md) when attendees ask how to continue after the workshop.

---

## Lab Flow (Read This First)

This workshop is built around a **pre-configured, repository-root lab environment**. No setup friction. No manual HCP Terraform configuration. Just find your repo, open it, and code.

### Intro Step 1: Access Your Pre-Created Repository (5 min)

Your instructor has already created a repository for you in the `a-demo-organization` GitHub organization. You do not need to fork or create your own—just find it and get started.

**Step 1: Navigate to your repository**

1. Go to **`github.com/a-demo-organization`**
2. Find your pre-created repository — it follows the pattern **`powershell-summit-terraform-workshop-{your-github-username}-{random-letters}`**
3. Open that repository
4. This is your "learner copy" — a full copy of the workshop repo where you'll write code and push changes

**Why:**
- Every push comes from YOUR pre-created repository
- HCP Terraform runs are isolated to your learner copy
- You can safely experiment without affecting others
- Deployment is triggered when you push to `main` in YOUR copy

### Intro Step 2: Open in GitHub Codespaces (5 min)

The lab environment **is** GitHub Codespaces. Everything is pre-configured:
- Terraform CLI
- Azure CLI
- Git
- GitHub Copilot
- HashiCorp Terraform extensions
- HCP Terraform wiring (already connected to your learner copy)

**Step 1: Open your learner copy in Codespaces**

1. Go to your pre-created repository (from Intro Step 1 above)
2. Click **Code** (green button)
3. Click **Codespaces**
4. Click **Create codespace on main**
5. GitHub spins up a full VS Code environment in your browser
6. Wait ~60 seconds for the environment to boot

**Step 2: Verify tools are available**

Once the Codespace is open, open a terminal and run:

```bash
terraform version
az --version
git --version
```

All three should report versions. If any fail, refresh the page and wait another 30 seconds.

**Why Codespaces:**
- No installation friction (everything is pre-configured)
- Same environment for every participant (no "it works on my machine" problems)
- HCP Terraform is already wired to your learner copy
- Your code is safe if your laptop dies

---

## Intro Step 3: Understand the Deployment Model (3 min)

## Speaker Notes

### Opening Statement

"Today we are skipping environment yak-shaving. You are starting from a preconfigured, repository-root lab environment in GitHub Codespaces. Your deployment model is simple: edit, commit, push, and HCP Terraform automatically runs the plan and apply."

### Core Workflow for Every Hands-On Chapter

```text
1. Edit Terraform in your learner copy (in Codespaces)
2. Run local checks (fmt, validate)
3. Commit and push to main in your learner copy
4. HCP Terraform automatically runs the plan and apply
5. Review the run results in the HCP UI or Azure portal
```

Use this command sequence repeatedly:

```bash
git add .
git commit -m "lab: update"
git push origin main
```

**After you push:**
- HCP Terraform detects the push to your learner copy's `main` branch
- It automatically runs `terraform plan` to show what will change
- It automatically runs `terraform apply` to deploy changes
- You can review the run output in the HCP Terraform UI
- Resources appear in your Azure resource group

---

## Quick Readiness Check

Before moving on:
- [ ] You can access your pre-created repository in the `a-demo-organization` GitHub organization
- [ ] You have opened it in GitHub Codespaces
- [ ] Commands run from the repository root in the Codespace
- [ ] `terraform version` succeeds
- [ ] `git --version` succeeds
- [ ] Participant understands: deployment is triggered by `git push origin main` from their learner copy

---

## Transition to Chapter 2

"Now that you're in the preconfigured environment and understand the push-based deployment model, we can dive into Terraform fundamentals. Keep the push-based loop in mind—you'll use it in every hands-on exercise."

---

## Agenda Preview (Core Path)

**Estimated total time: ~150-175 min core path | +30–35 min with stretch goal**

```text
00) Prerequisites                   (~10 min)
01) Introduction and Setup          (~15 min)
02) Terraform Fundamentals          (~5 min)
03) Hands-On: First Resource        (~45-50 min, push-based deploy)
04) Deploy with AVM                 (~20-25 min, push-based deploy)
05) Copilot and MCP                 (~25-30 min, Copilot + Terraform MCP Server)
06) Skills and Knowledge            (~25-30 min, reusable IaC patterns)
07) Custom Agents (Stretch Goal — if time permits)  (~30-35 min, specialized Copilot agents)
08) Wrap-Up                         (~5-10 min)
```

> 📚 **Credentials & Security** content (Service Principals, environment variables, CI/CD credential patterns) is available as a bonus reference in [reference/bonus-credentials-security.md](./reference/bonus-credentials-security.md).

### Codespace Troubleshooting: HCP Terraform Authentication

If `terraform init` or `terraform login` doesn't authenticate in Codespaces:

```powershell
# Set the HCP token as an environment variable (most reliable method)
$env:TF_TOKEN_app_terraform_io = "your-hcp-token"
$env:TF_TOKEN_APP_TERRAFORM_IO = "your-hcp-token"
```

This environment variable method is preferred in containerized environments and is more reliable than file-based credential storage. The token will persist for your Codespace session.

**Bonus deep-dives** available after the workshop in the [reference/](./reference/) folder:
- [reference/bonus-hcp-terraform-setup.md](./reference/bonus-hcp-terraform-setup.md) (HCP setup/auth details)
- [reference/bonus-org-scaling.md](./reference/bonus-org-scaling.md), [reference/bonus-governance-and-team-workflows.md](./reference/bonus-governance-and-team-workflows.md), and more

---

**Next:** [Chapter 2: Terraform Fundamentals](./02_Terraform_Fundamentals.md)
