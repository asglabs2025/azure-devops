// rg.bicep
// This module creates a Resource Group.
// All values (name, location, tags) are passed in from lz-deploy.ps1.

// Parameters
param rgName string                  // Resource Group name
param location string = 'uksouth'    // Region (default UK South, overridden by lz-deploy.ps1)
param rgTags object = {}             // Optional tags (key/value pairs)

// Target scope: subscription
// Resource groups are created at subscription scope, not inside another resource group
targetScope = 'subscription'

// Resource Group definition
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: rgTags
}

// Output the Resource Group ID so other modules or scripts can reference it
output resourceGroupId string = rg.id
