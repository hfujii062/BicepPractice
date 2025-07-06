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
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'AutomaticByPlatform'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: 'ubuntu-24_04-lts'
        sku: sku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        osType: 'Linux'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: managedDiskType
        }
        name: '${vmName}-osdisk'
        deleteOption: 'Delete'
        diskSizeGB: 30
      }
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
