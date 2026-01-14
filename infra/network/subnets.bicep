param vnetName string

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: '${vnetName}/snet-aks'
  properties: {
    addressPrefix: '10.10.1.0/24'
  }
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: '${vnetName}/snet-appsvc-integration'
  properties: {
    addressPrefix: '10.10.2.0/24'
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: '${vnetName}/snet-private-endpoints'
  properties: {
    addressPrefix: '10.10.3.0/24'
  }
}

output aksSubnetId string = aksSubnet.id
output appSubnetId string = appSubnet.id
output peSubnetId string = peSubnet.id
