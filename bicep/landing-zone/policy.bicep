// policy.bicep
// This module assigns policies at either subscription or resource group scope.
// It enforces:
// 1. "Allowed locations = UK South" for resources
// 2. "Allowed locations = UK South" for resource groups
// You can also pass in extra policy assignments from lz-deploy.ps1.

// Parameters
param scopeType string                         // "subscription" or "resourceGroup"
param policyAssignments array = []             // Optional extra policies
param location string = 'uksouth'              // Default region (UK South)

// Decide scope based on scopeType
var assignmentScope = scopeType == 'subscription' ? subscription() : resourceGroup()

// Built-in policy definition IDs
var allowedLocationsResourcesPolicyDefId = '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
var allowedLocationsRGsPolicyDefId        = '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'

// Deploy any extra policies passed in from lz-deploy.ps1
resource pa 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for (p, i) in policyAssignments: {
  name: 'lz-policy-${i}'
  scope: assignmentScope
  properties: {
    displayName: p.displayName
    policyDefinitionId: p.policyDefinitionId
    parameters: p.parameters
    enforcementMode: 'Default'
  }
  location: location
}]

// Always enforce Allowed Locations = UK South for resources
resource allowedLocationsResourcesAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'allowed-locations-resources-uksouth'
  scope: assignmentScope
  properties: {
    displayName: 'Restrict resource deployments to UK South'
    policyDefinitionId: allowedLocationsResourcesPolicyDefId
    parameters: {
      listOfAllowedLocations: {
        value: [
          location
        ]
      }
    }
    enforcementMode: 'Default'
  }
  location: location
}

// Always enforce Allowed Locations = UK South for resource groups
resource allowedLocationsRGsAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'allowed-locations-rgs-uksouth'
  scope: assignmentScope
  properties: {
    displayName: 'Restrict resource groups to UK South'
    policyDefinitionId: allowedLocationsRGsPolicyDefId
    parameters: {
      listOfAllowedLocations: {
        value: [
          location
        ]
      }
    }
    enforcementMode: 'Default'
  }
  location: location
}
