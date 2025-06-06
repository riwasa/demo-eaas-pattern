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

@description('The name of the pipeline that will deploy the environment.')
param pipelineName string

@description('The run id of the pipeline')
param pipelineRunId string

@description('The name of the user who triggered the pipeline.')
param pipelineTriggerUser string

@description('The name of the user parameters file.')
param userInputParamFile string

@description('The size of the environment stamp.')
@allowed([
  'Small'
  'Medium'
  'Large'
])
param eaasStampSize string

@description('The name of the resource group to create. This will be unique for each deployment.')
param resourceGroupName string = 'MRNG-EaaS-Stamp-${uniqueString(newGuid())}'

var eaasTemplateNameAndVersion string = 'main.bicep@1.0.0'

var tags object = {
  AppCatId: appCatId
  eaasEndDate: eaasEndDate
  eaasServiceNowTicketId: eaasServiceNowTicketId
  eaasRequestorTeam: eaasRequestorTeam
  eaasStampSize: eaasStampSize
  eaasTemplateNameAndVersion: eaasTemplateNameAndVersion
  pipelineNameAndVersion: pipelineName
  pipelineRunId: pipelineRunId
  pipelineTriggerUser: pipelineTriggerUser
  userInputParamFile: userInputParamFile  
}

targetScope = 'subscription'

var stampSize string = toLower(eaasStampSize)

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
module smallStamp 'small.bicep' = if (stampSize == 'small') {
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

var smallRunCost string = ((stampSize == 'small') ? smallStamp.outputs.dailyRunCost : null)!
var mediumRunCost string = ((stampSize == 'medium') ? '45.67' : null)!
var largeRunCost string = ((stampSize == 'large') ? '67.89' : null)!

output dailyRunCost string = largeRunCost ?? mediumRunCost ?? smallRunCost ?? '0.00'
output eaasEndDate string = eaasEndDate
output resourceGroupName string = resourceGroupName
