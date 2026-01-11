param location string
param pipApimId string

resource apim 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: 'apim-ddns-prod'
  location: location
  sku: {
    name: 'StandardV2'
    capacity: 1
  }
  properties: {
    publisherName: 'Your Company'
    publisherEmail: 'admin@yourcompany.com'
    publicIPAddresses: [pipApimId]
  }
}

output apimHostname string = apim.properties.gatewayUrl
