# Azure Bicep Infrastructure Repository

A modular setup for managing Azure deployments with [Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview) and Azure DevOps pipelines.  
Pipelines are configured to trigger automatically on GitHub pushes for seamless automation.

---

## 📂 Folder Structure

- **`landing-zone/`**  
  Module folder containing Bicep templates for the landing zone.  
  Includes its own `README.md` describing usage and deployment details.

- **`pipelines/`**  
  Central folder for Azure DevOps pipeline definitions (`.yml` files).  
  Each pipeline file corresponds to a module folder and orchestrates its deployment.

## 🔮 Expansion Plan

- Additional deployment modules will be added alongside `landing-zone`.
- Pipelines remain centralised in the `pipelines/` folder.
- Each subfolder will document its own usage and specifics.

---