param location string

resource asp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-ddns-prod'
  location: location
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output aspId string = asp.id
