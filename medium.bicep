param location string
param tags object

var dailyRunCost string = '189.12'

module storageAccount 'storage.bicep' = {
  name: 'StorageAccount'
  params: {
    location: location
    skuName: 'Standard_LRS'
    storageAccountName: 'eaasmed${uniqueString(resourceGroup().id)}st'
    tags: tags
  }
}

output dailyRunCost string = dailyRunCost
output storageAccountName string = storageAccount.name
