@description('The password for the virtual machine administrator.')
@secure()
param adminPassword string

@description('The admin username for the virtual machine.')
param adminUsername string

@description('The email address to receive notifications for the auto-shutdown of the virtual machine.')
param autoShutdownEmailRecipient string

@description('The location of the resources.')
param location string

@description('The tags to apply to the resources.')
param tags object

var autoShutdownTime = '22:00'
var enableAcceleratedNetworking = true
var hibernationEnabled = false
var nicDeleteOption = 'Delete'
var osDiskCreateOption = 'FromImage'
var osDiskDeleteOption = 'Delete'
var osDiskType = 'Premium_LRS'
var vmSize = 'Standard_D4s_v5'
var vNetName = 'rim-demo-eaas-vnet'
var vNetResourceGroupName = 'rim-demo-eaas-rg'
var vNetSubnetName = 'default'
var windowsLicenseType = 'Windows_Server'

var dataDisk1 = {
  caching: 'None'
  createOption: 'Empty'
  deleteOption: 'Delete'
  diskSizeGB: 128
  managedDisk: {
    storageAccountType: 'Premium_LRS'
  }
}

var dataDisk2 = {
  caching: 'ReadOnly'
  createOption: 'Empty'
  deleteOption: 'Delete'
  diskSizeGB: 128
  managedDisk: {
    storageAccountType: 'Premium_LRS'
  }
}

var dataDisks = [
  dataDisk1
  dataDisk2
]

var vmParams array = [
  {
    adminPassword: adminPassword
    adminUsername: adminUsername
    autoShutdownEmailRecipient: autoShutdownEmailRecipient
    autoShutdownTime: autoShutdownTime
    dataDisks: dataDisks
    enableAcceleratedNetworking: enableAcceleratedNetworking
    hibernationEnabled: hibernationEnabled
    location: location
    nicDeleteOption: nicDeleteOption
    osDiskCreateOption: osDiskCreateOption
    osDiskDeleteOption: osDiskDeleteOption
    osDiskType: osDiskType
    vmSize: vmSize
    vNetName: vNetName
    vNetResourceGroupName: vNetResourceGroupName
    vNetSubnetName: vNetSubnetName
    windowsLicenseType: windowsLicenseType
    tags: union(tags, {
      eaasAllowShutdown: 'night'
    })
  }
  {
    adminPassword: adminPassword
    adminUsername: adminUsername
    autoShutdownEmailRecipient: autoShutdownEmailRecipient
    autoShutdownTime: autoShutdownTime
    dataDisks: dataDisks
    enableAcceleratedNetworking: enableAcceleratedNetworking
    hibernationEnabled: hibernationEnabled
    location: location
    nicDeleteOption: nicDeleteOption
    osDiskCreateOption: osDiskCreateOption
    osDiskDeleteOption: osDiskDeleteOption
    osDiskType: osDiskType
    vmSize: vmSize
    vNetName: vNetName
    vNetResourceGroupName: vNetResourceGroupName
    vNetSubnetName: vNetSubnetName
    windowsLicenseType: windowsLicenseType
    tags: union(tags, {
      eaasAllowShutdown: 'night'
    })
  }
  {
    adminPassword: adminPassword
    adminUsername: adminUsername
    autoShutdownEmailRecipient: ''
    autoShutdownTime: ''
    dataDisks: dataDisks
    enableAcceleratedNetworking: enableAcceleratedNetworking
    hibernationEnabled: hibernationEnabled
    location: location
    nicDeleteOption: nicDeleteOption
    osDiskCreateOption: osDiskCreateOption
    osDiskDeleteOption: osDiskDeleteOption
    osDiskType: osDiskType
    vmSize: 'Standard_D2s_v5'
    vNetName: vNetName
    vNetResourceGroupName: vNetResourceGroupName
    vNetSubnetName: vNetSubnetName
    windowsLicenseType: windowsLicenseType
    tags: tags
  }
]

// Create virtual machines.
module vms 'vm.bicep' = [for i in range(0, length(vmParams)): {
  name: 'VirtualMachine-${i}'
  params: {
    adminPassword: vmParams[i].adminPassword
    adminUsername: vmParams[i].adminUsername
    autoShutdownEmailRecipient: empty(vmParams[i].autoShutdownEmailRecipient) ? '' : vmParams[i].autoShutdownEmailRecipient
    autoShutdownTime: empty(vmParams[i].autoShutdownTime) ? '' : vmParams[i].autoShutdownTime
    dataDisks: vmParams[i].dataDisks
    enableAcceleratedNetworking: vmParams[i].enableAcceleratedNetworking
    hibernationEnabled: vmParams[i].hibernationEnabled
    location: vmParams[i].location
    nicDeleteOption: vmParams[i].nicDeleteOption
    osDiskCreateOption: vmParams[i].osDiskCreateOption
    osDiskDeleteOption: vmParams[i].osDiskDeleteOption
    osDiskType: vmParams[i].osDiskType
    vmSize: vmParams[i].vmSize
    vNetName: vmParams[i].vNetName
    vNetResourceGroupName: vmParams[i].vNetResourceGroupName
    vNetSubnetName: vmParams[i].vNetSubnetName
    windowsLicenseType: vmParams[i].windowsLicenseType
    tags: vmParams[i].tags
  }
}]

output vmNames array = [
  for i in range(0, length(vmParams)): vms[i].outputs.vmName
]
