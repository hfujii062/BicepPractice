targetScope = 'subscription'

@description('デプロイ先のAzureリージョン')
param location string = 'japaneast'

@description('管理者のユーザー名')
@maxLength(20)
@minLength(1)
param adminUsername string

@description('管理者のパスワード')
@secure()
@maxLength(123)
@minLength(12)
param adminPassword string

@description('リソースグループ名')
param resourceGroupName string


@description('仮想ネットワーク名')
param vnetName string

@description('仮想ネットワークのアドレス範囲')
param addressRange string

@description('デフォルトサブネットアドレス範囲')
param defaultSubnetRange string

@description('ゲートウェイサブネットアドレス範囲')
param gatewaySubnetRange string

@description('デプロイ先サブネット名')
param destSubnetName string

@description('VMデプロイ先サブネットのアドレス範囲')
param destAddressRange string = '10.0.1.0/24'

@description('パブリックIPアドレス名のサフィックス')
param publicIpNameSuffix string

@description('NIC名のサフィックス')
param nicNameSuffix string

@description('NSG名')
param nsgName string

@description('VM情報')
var vmOfOptions array = [
  { name: 'bicep-vm1', sku: '2022-datacenter-g2', size: 'Standard_D2s_v5', diskType: 'Standard_LRS', dataDiskSizeInGb: 0 }
  { name: 'bicep-vm2', sku: '2022-datacenter-g2', size: 'Standard_D2s_v5', diskType: 'StandardSSD_LRS', dataDiskSizeInGb: 32 }
]

@description('VMのセキュリティの種類')
var vmSecurityType = 'TrustedLaunch'

// Create a resource group in the specified location
@description('リソースグループの作成')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

// Deploy the virtual network module
@description('仮想ネットワークのデプロイ')
module vnetMod 'vnet.bicep' = {
  name: 'vnetModule'
  scope: resourceGroup
  params: {
    vnetName: vnetName
    addressPrefix: addressRange
    defaultSubnetPrefix: defaultSubnetRange
    secondarySubnetName: destSubnetName
    secondarySubnetPrefix: destAddressRange
    gatewaySubnetPrefix: gatewaySubnetRange
    nsgName: nsgName
  }
}

// Deploy the public IP module
@description('パブリックIPアドレスのデプロイ')
module publicIpMods 'pip.bicep' = [ for i in range(1, length(vmOfOptions)): {
  name: 'publicIpModule${i}'
  scope: resourceGroup
  params: {
    publicIpName: '${vmOfOptions[i-1].name}-${publicIpNameSuffix}'
  }
}]

// Deploy the network interface modules
@description('ネットワークインターフェイスのデプロイ')
module nicMods 'nic.bicep' = [ for i in range(1, length(vmOfOptions)): {
  name: 'nicModule${i}'
  scope: resourceGroup
  params: {
    nicName: '${vmOfOptions[i-1].name}-${nicNameSuffix}'
    subnetId: vnetMod.outputs.secondarySubnetId
    publicIpId: publicIpMods[i-1].outputs.publicIpId
    nsgId: vnetMod.outputs.nsgId
  }
}]

// Deploy the virtual machine modules
@description('仮想マシンのデプロイ')
module vmMods 'vm_windows.bicep' = [ for i in range(1, length(vmOfOptions)): {
  name: 'vmModule${i}'
  scope: resourceGroup
  params: {
    vmName: vmOfOptions[i-1].name
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmOfOptions[i-1].size
    nicId: nicMods[i-1].outputs.nicId
    managedDiskType: vmOfOptions[i-1].diskType
    sku: vmOfOptions[i-1].sku
    securityType: vmSecurityType
    dataDiskSizeGB: vmOfOptions[i-1].dataDiskSizeInGb
  }
}]
