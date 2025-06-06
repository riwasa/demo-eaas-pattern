@description('The application catalog id.')
param appCatId string

@description('The Azure region where the environment will be deployed.')
param azureRegion string

@description('The id of the Azure subscription where the environment will be deployed.')
param azureSubscription string

@description('The end date for the environment.')
param eaasEndDate string

@description('The name of the team requesting the environment.')
param eaasRequestorTeam string

@description('The id of the ServiceNow ticket associated with the environment request.')
param eaasServiceNowTicketId string

@description('The size of the environment stamp.')
@allowed([
  'Small'
  'Medium'
  'Large'
])
param eaasStampSize string

@description('The name of the resource group to create. This will be unique for each deployment.')
param resourceGroupName string = 'MRNG-EaaS-Stamp-${uniqueString(newGuid())}'

var tags object = {
  AppCatId: appCatId
  eaasEndDate: eaasEndDate
  eaasServiceNowTicketId: eaasServiceNowTicketId
  eaasRequestorTeam: eaasRequestorTeam
  eaasStampSize: eaasStampSize
}

targetScope = 'subscription'

// Create a Resource Group.
module eaasResourceGroup 'resource-group.bicep' = {
  name: resourceGroupName
  params: {
    location: azureRegion
    resourceGroupName: resourceGroupName
    tags: tags
  }
  scope: subscription(azureSubscription)
}

// Call the appropriate module based on the environment stamp size.
module smallStamp 'small.bicep' = if (eaasStampSize == 'Small') {
  name: 'SmallEnvironmentStamp'
  dependsOn: [
    eaasResourceGroup
  ]
  params: {
    location: azureRegion
    tags: tags
  }
  scope: resourceGroup(resourceGroupName)
}

var smallRunCost string = ((eaasStampSize == 'Small') ? smallStamp.outputs.dailyRunCost : null)!
var mediumRunCost string = ((eaasStampSize == 'Medium') ? '45.67' : null)!
var largeRunCost string = ((eaasStampSize == 'Large') ? '67.89' : null)!

output dailyRunCost string = largeRunCost ?? mediumRunCost ?? smallRunCost ?? '0.00'
output eaasEndDate string = eaasEndDate
output resourceGroupName string = resourceGroupName
