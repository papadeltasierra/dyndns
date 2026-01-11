param location string

resource apiAi 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-ddns-api-prod'
  location: location
  kind: 'web'
}

resource portalAi 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-ddns-portal-prod'
  location: location
  kind: 'web'
}

output apiAppInsightsKey string = apiAi.properties.InstrumentationKey
output portalAppInsightsKey string = portalAi.properties.InstrumentationKey
