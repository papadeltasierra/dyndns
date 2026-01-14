param aksName string
param aksSubnetId string

resource userPool 'Microsoft.ContainerService/managedClusters/agentPools@2023-07-01' = {
  name: '${aksName}/userpool'
  properties: {
    count: 2
    vmSize: 'Standard_D4s_v5'
    mode: 'User'
    vnetSubnetID: aksSubnetId
  }
}
