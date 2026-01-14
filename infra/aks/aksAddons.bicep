param aksName string

resource insights 'Microsoft.ContainerService/managedClusters@2023-07-01' existing = {
  name: aksName
}

resource addonOms 'Microsoft.ContainerService/managedClusters@2023-07-01' = {
  name: aksName
  properties: {
    addonProfiles: {
      omsagent: {
        enabled: true
      }
    }
  }
}
