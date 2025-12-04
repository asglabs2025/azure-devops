// observability.bicep
// This module creates a Log Analytics workspace for monitoring and observability.
// All values (name, location, etc.) are passed in from lz-deploy.ps1.

// Parameters
param laName string                          // Name of the Log Analytics workspace
param location string = resourceGroup().location // Region (defaults to RG location)

// Log Analytics workspace resource
resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: laName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'                      // Pricing tier (most common choice)
    }
    retentionInDays: 30                      // Retain logs for 30 days (adjust as needed)
  }
}

// Output the workspace ID so other modules or scripts can reference it
output workspaceId string = workspace.id
