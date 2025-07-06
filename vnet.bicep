param vnetName string
param location string = resourceGroup().location
param addressPrefix string
param defaultSubnetPrefix string
param secondarySubnetName string
param secondarySubnetPrefix string
param gatewaySubnetPrefix string
param nsgName string

@description('NSGモジュールの参照')
module nsgMod1 'nsg.bicep' = {
  name: 'nsgModule'
  scope: resourceGroup()
  params: {
    nsgName: nsgName
    location: location
    destAddressPrefix: secondarySubnetPrefix
  }
}

// Define a virtual network with subnets, referencing module outputs directly
@description('仮想ネットワークの作成')
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: defaultSubnetPrefix
        }
      }
      {
        
        name: secondarySubnetName
        properties: {
          addressPrefix: secondarySubnetPrefix
          // Reference the NSG module output directly
          networkSecurityGroup: {
            id: nsgMod1.outputs.nsgId
          }
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output defaultSubnetId string = vnet.properties.subnets[0].id
output secondarySubnetId string = vnet.properties.subnets[1].id
output nsgId string = nsgMod1.outputs.nsgId
