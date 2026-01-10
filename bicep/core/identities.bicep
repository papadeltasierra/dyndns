param location string

resource miApi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-ddns-api'
  location: location
}

resource miPortal 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-ddns-portal'
  location: location
}

resource miRfc 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-ddns-rfc2136'
  location: location
}

output miApiId string = miApi.id
output miPortalId string = miPortal.id
output miRfcId string = miRfc.id
