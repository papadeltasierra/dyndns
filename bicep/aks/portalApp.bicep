param location string
param aspId string
param miPortalId string

resource portalApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-ddns-portal-prod'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${miPortalId}': {}
    }
  }
  properties: {
    serverFarmId: aspId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
  }
}
