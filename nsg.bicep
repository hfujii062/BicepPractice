param location string = resourceGroup().location
param nsgName string
param destAddressPrefix string

var sourcePortRange = '*'
var destinationPortRange = '*'

// Create a Network Security Group (NSG) with security rules
@description('ネットワークセキュリティグループの作成')
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  location: location
  name: nsgName
  properties: {
    securityRules: [
      {
        name: 'AllowRdp'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: sourcePortRange
          destinationPortRange: '3389'
          sourceAddressPrefix: destinationPortRange
          destinationAddressPrefix: destAddressPrefix
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: sourcePortRange
          destinationPortRange: '443'
          sourceAddressPrefix: destinationPortRange
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1010
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: sourcePortRange
          destinationPortRange: '80'
          sourceAddressPrefix: destinationPortRange
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1020
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowInSqlServer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: sourcePortRange 
          destinationPortRange: '1433'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 1030
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgName string = nsg.name
output nsgId string = nsg.id
