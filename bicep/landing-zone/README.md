# Azure DevOps Landing Zone Deployment (PowerShell + Bicep)

This repository contains an **Azure Landing Zone deployment pipeline** built with **Azure DevOps**, **PowerShell**, and **Bicep**. It provisions a complete landing zone environment including networking, observability, security, RBAC, and policy enforcement. Authentication is handled by a **Service Connection** with federated credentials.

---

## ⚠️ Important Note on Permissions
For lab purposes, a **custom role definition** was used with broad permissions. This is **less restrictive than recommended for production**. The role includes:

- `Microsoft.Resources/*`
- `Microsoft.Compute/*`
- `Microsoft.Storage/*`
- `Microsoft.Network/*`
- `Microsoft.KeyVault/*`
- `Microsoft.Authorization/*`
- `Microsoft.PolicyInsights/*`
- `Microsoft.Authorization/policyDefinitions/*`
- `Microsoft.Authorization/policyAssignments/*`
- `Microsoft.Management/managementGroups/*`
- `Microsoft.Resources/deployments/*`

In production, you should scope permissions more tightly to follow least‑privilege principles.

---

## 🚀 How to Use

### 1. Configure Variables
Edit the variables at the top of **`lz-deploy.ps1`**:
- Subscription, tenant, and client IDs (if required).
- Resource group name, VNet name, address space, subnet prefixes.
- Log Analytics workspace name.
- Key Vault name.
- RBAC assignments (replace with real Entra ID object IDs).

JSON files (`rgTags.json`, `subnets.json`, `rbac.json`) are **generated automatically during deployment** from these variables. You only need to define the variables in the script.

---

### 2. Configure Pipeline
Update **`landing-zone.yml`** with environment specifics:
- Branch triggers.
- Agent pool (e.g. self‑hosted Windows agent).
- Service connection name (for federated identity).
- Script path.

This repo is configured to run on a **self‑hosted Azure DevOps server**.

---

### 3. Run Deployment
The pipeline executes `lz-deploy.ps1`, which:
1. Writes JSON parameter files.
2. Calls `az deployment sub create` and `az deployment group create` for each Bicep module.
3. Deploys resources in sequence.

---

## 📦 Bicep Modules

- **`network.bicep`**  
  Deploys a VNet with multiple subnets. Each subnet has an attached NSG with example rules.

- **`observability.bicep`**  
  Deploys a Log Analytics Workspace.

- **`policy.bicep`**  
  Enforces allowed locations for resources and resource groups. Can be extended with custom policies.

- **`rg.bicep`**  
  Creates the resource group for the landing zone deployment.

- **`roleassignments.bicep`**  
  Assigns RBAC permissions to a chosen scope. Can be amended to match your environment.

- **`security.bicep`**  
  Deploys a Key Vault with RBAC enabled.

---

## ✅ Notes
- For production, replace the lab role definition with a more restrictive one.
- Ensure your service principal has **Owner** or **User Access Administrator** rights if you want RBAC assignments to succeed.

---

## 📖 References
- [Azure Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview)
- [Azure DevOps pipelines](https://learn.microsoft.com/azure/devops/pipelines/?view=azure-devops)
- [ARM template deployments](https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-cli)

---

### Landing Zone deployed successfully 🎉