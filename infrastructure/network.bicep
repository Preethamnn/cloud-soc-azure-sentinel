param location string = resourceGroup().location

resource nsgWorkload 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-workload'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-RDP-Mgmt'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '<YOUR_TRUSTED_SOURCE_IP_OR_RANGE>'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'soc-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'workload'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsgWorkload.id
          }
        }
      }
      {
        name: 'mgmt'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
