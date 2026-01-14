param location string
param aspId string
param miApiId string
param sqlConnectionString string

resource apiApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'app-ddns-api-prod'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${miApiId}': {}
    }
  }
  properties: {
    serverFarmId: aspId
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: [
        { name: 'SQL_CONNECTION_STRING'; value: sqlConnectionString }
      ]
    }
  }
}
