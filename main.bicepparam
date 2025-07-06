using 'main.bicep'

param adminUsername = 'AzureUser'

param adminPassword = 'P@ssw0rd12345'

param resourceGroupName = 'RG_BICEP'

param vnetName = 'bicep-vnet'

param addressRange = '10.0.0.0/16'

param defaultSubnetRange = '10.0.0.0/24'

param gatewaySubnetRange =  '10.0.10.0/24'

param destSubnetName = 'bicep-subnet'

param publicIpNameSuffix = 'bicep-pip'

param nicNameSuffix = 'bicep-nic'

param nsgName = 'bicep-nsg'
