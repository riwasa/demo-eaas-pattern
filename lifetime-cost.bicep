@description('The Azure region where the environment will be deployed.')
param azureRegion string

@description('The lifetime cost of the environment.')
param lifetimeCost string

@description('The name of the Resource Group.')
param resourceGroupName string

@description('The existing tags for the Resource Group.')
param tags object

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: azureRegion
  tags: union(tags, {
    lifetimeCost: lifetimeCost
  })
}
