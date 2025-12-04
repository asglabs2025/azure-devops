// network.bicep
// This module creates a Virtual Network (VNet) with subnets and NSGs.
// All values (name, address space, subnets, location) are passed in from lz-deploy.ps1.

// Parameters
param vnetName string                           // Name of the VNet
param location string = resourceGroup().location // Region (defaults to RG location)
param vnetAddressSpace string                   // CIDR block for the VNet (e.g. "10.10.0.0/16")
param subnets array                             // Array of subnets (name + prefix)
param rgName string                             // Resource group name for NSG to reference subnets

// VNet resource
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    // Loop through the subnets array passed in from lz-deploy.ps1
    subnets: [
      for s in subnets: {
        name: s.name
        properties: {
          addressPrefix: s.prefix
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', rgName, '${s.name}-nsg')
          }
        }
      }
    ]
  }
}

// Create NSGs for each subnet
resource nsgs 'Microsoft.Network/networkSecurityGroups@2023-05-01' = [for s in subnets: {
  name: '${s.name}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}]

// Output the VNet ID so other modules or scripts can reference it
output vnetId string = vnet.id
