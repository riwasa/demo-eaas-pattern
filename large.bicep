param location string
param tags object

var dailyRunCost string = '561.76'

module storageAccount 'storage.bicep' = {
  name: 'StorageAccount'
  params: {
    location: location
    skuName: 'Standard_LRS'
    storageAccountName: 'eaaslrg${uniqueString(resourceGroup().id)}st'
    tags: tags
  }
}

output dailyRunCost string = dailyRunCost
output storageAccountName string = storageAccount.name
