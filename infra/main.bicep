param location string = resourceGroup().location

module core './core/core.bicep' = {
    name: 'core'
  params: {
        location: location
    }
}

module network './network/network.bicep' = {
    name: 'network'
  params: {
        location: location
    }
}

module aks './aks/aksCluster.bicep' = {
    name: 'aks'
  params: {
        location: location
    vnetId: network.outputs.vnetId
    aksSubnetId: network.outputs.aksSubnetId
    miRfcId: core.outputs.miRfcId
    }
}

module app './app/app.bicep' = {
    name: 'app'
  params: {
        location: location
    miApiId: core.outputs.miApiId
    miPortalId: core.outputs.miPortalId
    sqlConnectionString: core.outputs.sqlConnectionString
    }
}

module monitoring './monitoring/monitoring.bicep' = {
    name: 'monitoring'
  params: {
        location: location
    }
}
