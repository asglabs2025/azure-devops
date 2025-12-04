// roleassignments.bicep
// This module applies RBAC role assignments at the resource group scope.
// The actual principal IDs and roles are passed in from lz-deploy.ps1.

// Parameter: an array of assignments
// Each item in the array should look like:
// { roleDefinitionId: "Owner", principalId: "<OBJECT-ID>" }
param assignments array

// Map friendly role names to their well-known GUIDs
// These GUIDs are the built-in role definition IDs in Azure
var roleMap = {
  Owner:        '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor:  'b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader:       'acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

// Create a role assignment for each entry in the assignments array
// Use resourceGroup().id for RG-scoped assignments
// Use subscription().id for subscription-scoped assignments
resource ra 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (a, i) in assignments: {
  // Generate a unique name for the role assignment using GUID
  name: guid(resourceGroup().id, a.principalId, a.roleDefinitionId, string(i))

  // Scope of the assignment
  // Change to subscription() if you want this role to apply to the entire subscription
  scope: resourceGroup()

  properties: {
    // Look up the role definition ID from the roleMap
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      roleMap[a.roleDefinitionId]
    )

    // Principal ID (object ID of user, group, or service principal in Entra ID)
    principalId: a.principalId

    // Type of principal (can be 'User', 'Group', 'ServicePrincipal', etc.)
    principalType: 'Group'
  }
}]
