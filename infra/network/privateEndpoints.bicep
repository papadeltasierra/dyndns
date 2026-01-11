param location string
param peSubnetId string
param sqlServerName string
param keyVaultName string

resource sqlPe 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pe-sql'
  location: location
  properties: {
    subnet: { id: peSubnetId }
    privateLinkServiceConnections: [
      {
        name: 'sql'
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Sql/servers', sqlServerName)
          groupIds: ['sqlServer']
        }
      }
    ]
  }
}

resource kvPe 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: 'pe-kv'
  location: location
  properties: {
    subnet: { id: peSubnetId }
    privateLinkServiceConnections: [
      {
        name: 'kv'
        properties: {
          privateLinkServiceId: resourceId('Microsoft.KeyVault/vaults', keyVaultName)
          groupIds: ['vault']
        }
      }
    ]
  }
}
