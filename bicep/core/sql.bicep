param location string
param sqlAdminUser string
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: 'ddnssql-prod'
  location: location
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPassword
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${sqlServer.name}/ddns-config-db'
  sku: {
    name: 'GP_Gen5_2'
  }
}

output sqlConnectionString string = 'Server=tcp:${sqlServer.name}.database.windows.net;Database=${sqlDb.name};'
output sqlServerName string = sqlServer.name
output sqlDbName string = sqlDb.name
