param location string
param tenantId string

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-ddns-prod'
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}

output keyVaultUri string = kv.properties.vaultUri
