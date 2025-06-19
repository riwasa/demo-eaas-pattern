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
var vmSize = 'Standard_D2s_v5'
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

var dataDisks = [
  dataDisk1
]

// Create a virtual machine with an auto-shutdown schedule.
module vmWithShutdown 'vm.bicep' = {
  name: 'VirtualMachineWithShutdown'
  params: {
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
}

output vmNames array = [
  vmWithShutdown.outputs.vmName
]
