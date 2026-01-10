param location string
param vnetId string
param aksSubnetId string
param miRfcId string

resource aks 'Microsoft.ContainerService/managedClusters@2023-07-01' = {
  name: 'aks-ddns-prod'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'ddns-aks'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 2
        vmSize: 'Standard_D2s_v5'
        mode: 'System'
        vnetSubnetID: aksSubnetId
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: '10.20.0.0/16'
      dnsServiceIp: '10.20.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
    }
    oidcIssuerProfile: {
      enabled: true
    }
  }
}

output aksName string = aks.name
