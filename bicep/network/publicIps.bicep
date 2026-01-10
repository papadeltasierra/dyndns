param location string

resource pipRfc 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'pip-ddns-rfc2136-prod'
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource pipApim 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'pip-ddns-apim-prod'
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

output pipRfcId string = pipRfc.id
output pipApimId string = pipApim.id
