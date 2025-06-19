@description('The admin password.')
@secure()
param adminPassword string

@description('The admin username.')
@secure()
param adminUsername string

@description('The email address to receive notifications for the auto-shutdown of the virtual machine.')
param autoShutdownEmailRecipient string?

@description('The time in 24 hour format for the auto-shutdown of the virtual machine.')
param autoShutdownTime string?

@description('The data disks to attach to the virtual machine.')
param dataDisks dataDiskType[]?

@description('Indicates whether accelerated networking is enabled for the virtual machine.')
param enableAcceleratedNetworking bool

@description('Indicates whether hibernation is enabled for the virtual machine.')
param hibernationEnabled bool

@description('The location of the resources.')
param location string

@description('Indicates how the network interface should be handled when the virtual machine is deleted.')
@allowed([
  'Detach'
  'Delete'
])
param nicDeleteOption string

@description('Indicates how the virtual machine should be created.')
@allowed([
  'Attach'
  'FromImage'
  'Empty'
])
param osDiskCreateOption string

@description('Indicates how the OS disk should be handled when the virtual machine is deleted.')
@allowed([
  'Detach'
  'Delete'
])
param osDiskDeleteOption string

@description('The type of OS disk for the virtual machine.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Premium_V2_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'UltraSSD_LRS'
])
param osDiskType string

@description('The tags to apply to the resources.')
param tags object

@description('The name of the virtual machine. This will be unique for each deployment.')
#disable-next-line use-stable-resource-identifiers // The name must be unique on every call.
#disable-next-line simplify-interpolation // Interpolation required for functions.
param vmName string = '${uniqueString(utcNow(), newGuid())}'

@description('The size of the virtual machine.')
param vmSize string

@description('The name of the virtual network to connect the VM to.')
param vNetName string

@description('The name of the Resource Group where the virtual network is located.')
param vNetResourceGroupName string

@description('The name of the subnet within the virtual network to connect the VM to.')
param vNetSubnetName string

@description('The type of Windows license for the virtual machine.')
@allowed([
  ''
  'Windows_Client'
  'Windows_Server'
]) 
param windowsLicenseType string

// Get the existing virtual network and subnet.
resource vNet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = if (!empty(vNetName)) {
  name: vNetName
  scope: resourceGroup(vNetResourceGroupName)
}

resource vNetSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  name: vNetSubnetName
  parent: vNet
}

// Create a network interface for the virtual machine.
resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  #disable-next-line use-stable-resource-identifiers // The name must be unique on every call.
  name: '${vmName}-nic'
  location: location
  dependsOn: [
    vNetSubnet
  ]
  properties: {
    enableAcceleratedNetworking: enableAcceleratedNetworking
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vNetSubnet.id
          }
        }
      }
    ]
  }
  tags: tags
}

// Create managed data disks for the virtual machine.
resource managedDataDisks 'Microsoft.Compute/disks@2024-03-02' = [
  for (dataDisk, index) in dataDisks ?? []: if (empty(dataDisk.managedDisk.?id)) {
    #disable-next-line use-stable-resource-identifiers // The name must be unique on every call.
    name: dataDisk.?name ?? '${vmName}-disk-${padLeft((index + 1), 2, '0')}'
    location: location
    properties: {
      diskSizeGB: dataDisk.diskSizeGB
      creationData: {
        createOption: dataDisk.?createoption ?? 'Empty'
      }
    }
    sku: {
      name: dataDisk.managedDisk.?storageAccountType
    }
    tags: tags
  }
]

// Create a virtual machine.
resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  #disable-next-line use-stable-resource-identifiers // The name must be unique on every call.
  name: vmName
  location: location
  dependsOn: [
    managedDataDisks
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    additionalCapabilities: {
      hibernationEnabled: hibernationEnabled
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    licenseType: windowsLicenseType
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
    }   
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: osDiskCreateOption
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      dataDisks: [
        for (dataDisk, index) in dataDisks ?? []: {
          lun: dataDisk.?lun ?? index
          name: !empty(dataDisk.managedDisk.?id)
            ? last(split(dataDisk.managedDisk.id ?? '', '/'))
            : dataDisk.?name ?? '${vmName}-disk-${padLeft((index + 1), 2, '0')}'
          createOption: (managedDataDisks[index].?id != null || !empty(dataDisk.managedDisk.?id))
            ? 'Attach'
            : dataDisk.?createoption ?? 'Empty'
          deleteOption: !empty(dataDisk.managedDisk.?id) ? 'Detach' : dataDisk.?deleteOption ?? 'Delete'
          caching: !empty(dataDisk.managedDisk.?id) ? 'None' : dataDisk.?caching ?? 'ReadOnly'
          managedDisk: {
            id: dataDisk.managedDisk.?id ?? managedDataDisks[index].?id
          }
        }
      ]
    }
  }
  tags: tags
}

// Create a schedule for auto-shutdown of the virtual machine.
// resource autoShutdownSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = if (!empty(autoShutdownTime) && !empty(autoShutdownEmailRecipient)) {
//   #disable-next-line use-stable-resource-identifiers // The name must be unique on every call.
//   name: 'shutdown-computevm-${vmName}'
//   location: location
//   properties: {
//     dailyRecurrence: {
//       time: autoShutdownTime
//     }
//     notificationSettings: {
//       emailRecipient: autoShutdownEmailRecipient
//       status: 'Enabled'
//       timeInMinutes: 15
//     }
//     status: 'Enabled'
//     targetResourceId: vm.id
//     taskType: 'ComputeVmShutdownTask'
//     timeZoneId: 'UTC'
//   }
//   tags: tags
// }

output vmName string = vmName

@description('The type describing a data disk.')
@export()
type dataDiskType = {
  @description('Optional. The disk name. When attaching a pre-existing disk, this name is ignored and the name of the existing disk is used.')
  name: string?

  @description('Optional. Specifies the logical unit number of the data disk.')
  lun: int?

  @description('Optional. Specifies the size of an empty data disk in gigabytes. This property is ignored when attaching a pre-existing disk.')
  diskSizeGB: int?

  @description('Optional. Specifies how the virtual machine should be created. This property is automatically set to \'Attach\' when attaching a pre-existing disk.')
  createOption: 'Attach' | 'Empty' | 'FromImage'?

  @description('Optional. Specifies whether data disk should be deleted or detached upon VM deletion. This property is automatically set to \'Detach\' when attaching a pre-existing disk.')
  deleteOption: 'Delete' | 'Detach'?

  @description('Optional. Specifies the caching requirements. This property is automatically set to \'None\' when attaching a pre-existing disk.')
  caching: 'None' | 'ReadOnly' | 'ReadWrite'?

  @description('Required. The managed disk parameters.')
  managedDisk: {
    @description('Optional. Specifies the storage account type for the managed disk. Ignored when attaching a pre-existing disk.')
    storageAccountType:
      | 'PremiumV2_LRS'
      | 'Premium_LRS'
      | 'Premium_ZRS'
      | 'StandardSSD_LRS'
      | 'StandardSSD_ZRS'
      | 'Standard_LRS'
      | 'UltraSSD_LRS'?

    @description('Optional. Specifies the resource id of a pre-existing managed disk. If the disk should be created, this property should be empty.')
    id: string?
  }

  @description('Optional. The tags of the public IP address. Valid only when creating a new managed disk.')
  tags: object?
}
