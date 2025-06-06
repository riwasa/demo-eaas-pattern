targetScope = 'subscription'

@description('The location of the Resource Group.')
param location string

@description('The name of the resource group to create. This will be unique for each deployment.')
param resourceGroupName string

@description('Tags to apply to the Resource Group.')
param tags object

// Create a Resource Group.
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: union(tags, {
    createdBy: 'Bicep'
  })
}

// Output the Resource Group name.
output resourceGroupName string = resourceGroup.name
