param location string
param tags object

module storageAccount 'storage.bicep' = {
  name: 'StorageAccount'
  params: {
    location: location
    skuName: 'Standard_LRS'
    storageAccountName: 'eaas${uniqueString(resourceGroup().id)}st'
    tags: tags
  }
}
