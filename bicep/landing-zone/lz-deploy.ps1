# Landing Zone Deployment Script
# This script defines variables and deploys all Bicep modules in sequence.

# --- VARIABLES (edit these only) ---
$location = "uksouth"                    # Azure region (UK South enforced by policy)

# Resource Group
$rgName = "uks-lz-prod-rg"
$rgTags = @{ "env" = "prod"; "owner" = "platform"; "costCenter" = "it" }

# Network
$vnetName = "uks-lz-prod-vnet"
$vnetAddressSpace = "10.10.0.0/16"
$subnets = @(
    @{ name = "app";  prefix = "10.10.1.0/24" },
    @{ name = "data"; prefix = "10.10.2.0/24" },
    @{ name = "mgmt"; prefix = "10.10.3.0/24" }
)

# Observability
$laName = "uks-lz-prod-law"

# Security
$keyVaultName = "uks-lz-prod-kv"

# RBAC assignments (replace with real object IDs from Entra ID)
$rbacAssignments = @(
    @{ roleDefinitionId = "Owner";       principalId = "5ba0be59-f2fb-4dac-9ba2-baafb30dcdf8" },
    @{ roleDefinitionId = "Contributor"; principalId = "e917ee34-7fb9-44a2-a26d-07fa8a3e5166" },
    @{ roleDefinitionId = "Reader";      principalId = "4b013a3d-6a70-4bc4-8731-4f34126e0a16" }
)

### Do not amend past this line ###

Set-Location "$PSScriptRoot"

# --- Write JSON files ---
$rgTags     | ConvertTo-Json -Depth 3 -Compress | Out-File -Encoding utf8 rgTags.json
$subnets    | ConvertTo-Json -Depth 3 -Compress | Out-File -Encoding utf8 subnets.json
$rbacAssignments | ConvertTo-Json -Depth 3 -Compress | Out-File -Encoding utf8 rbac.json
# If you later enable policyAssignments, do the same:
# $policyAssignments | ConvertTo-Json -Depth 3 -Compress | Out-File -Encoding utf8 policy.json

# --- Deployments ---
# Resource Group
az deployment sub create `
  --location $location `
  --template-file ./rg.bicep `
  --parameters rgName=$rgName location=$location rgTags=@rgTags.json

# Network
az deployment group create `
  --resource-group $rgName `
  --template-file ./network.bicep `
  --parameters vnetName=$vnetName vnetAddressSpace=$vnetAddressSpace subnets=@subnets.json location=$location

# Observability
az deployment group create `
  --resource-group $rgName `
  --template-file ./observability.bicep `
  --parameters laName=$laName location=$location

# Security
az deployment group create `
  --resource-group $rgName `
  --template-file ./security.bicep `
  --parameters keyVaultName=$keyVaultName location=$location enableRBAC=true

# RBAC
az deployment group create `
  --resource-group $rgName `
  --template-file ./roleassignments.bicep `
  --parameters assignments=@rbac.json

# Policies (optional)
az deployment group create `
  --resource-group $rgName `
  --template-file ./policy.bicep `
  --parameters scopeType="resourceGroup" location=$location
# If using extra policies:
# --parameters scopeType="resourceGroup" policyAssignments=@policy.json location=$location

Write-Host "Landing zone deployed successfully."