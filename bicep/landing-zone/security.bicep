// security.bicep
// This module creates an Azure Key Vault with recommended security settings.
// All values (name, location, RBAC toggle) are passed in from lz-deploy.ps1.

// Parameters
param keyVaultName string                       // Name of the Key Vault
param location string = resourceGroup().location // Region (defaults to RG location)
param enableRBAC bool = true                    // Whether to use RBAC instead of access policies

// Key Vault resource
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId           // Always tied to your tenant
    sku: {
      family: 'A'
      name: 'standard'                          // Standard SKU (most common choice)
    }
    enableRbacAuthorization: enableRBAC         // Modern RBAC model (true by default)
    enablePurgeProtection: true                 // Prevents permanent deletion (required for compliance)
    enableSoftDelete: true                      // Allows recovery of deleted vaults
    softDeleteRetentionInDays: 90               // Retain deleted vaults for 90 days
    publicNetworkAccess: 'Enabled'              // Allow public network access (can be set to 'Disabled' if using private endpoints)
  }
}

// Output the Key Vault resource ID so other modules can reference it
output keyVaultId string = kv.id
