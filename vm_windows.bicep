@description('デプロイ先のAzureリージョン')
param location string

@description('VM名')
param vmName string

@description('VMのサイズ')
param vmSize string

@description('管理者のユーザー名')
param adminUsername string

@description('管理者のパスワード')
@secure()
param adminPassword string

@description('NIC ID')
param nicId string

@description('ManagedDiskの種類')
param managedDiskType string = 'Standard_LRS'

@description('SKU')
param sku string = '2022-datacenter-azure-edition'

@description('セキュリティの種類')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

@description('VMのセキュリティ機能の構成')
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}

@description('データディスクのサイズ (GB)')
@allowed([
  0
  4
  8
  16
  32
  64
  128
  256
  512
  1024
  2048
  4096
  8192
  16384
  32768
] )
param dataDiskSizeGB int = 64


resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }    
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'AutomaticByPlatform'
          enableHotpatching: false
        }        
      }
      secrets: []
      allowExtensionOperations: true
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: sku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        osType: 'Windows'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: managedDiskType
        }
        name: '${vmName}-osdisk'
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: (dataDiskSizeGB > 0) ? [
        {createOption: 'Empty'
         lun: 0
         diskSizeGB: dataDiskSizeGB
         caching: 'ReadOnly'
         deleteOption: 'Delete'
         managedDisk: {
           storageAccountType: managedDiskType
         }
         name: '${vmName}-datadisk'
        }
      ] : [
      ]
      diskControllerType: 'SCSI'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}

output vmId string = vm.id
