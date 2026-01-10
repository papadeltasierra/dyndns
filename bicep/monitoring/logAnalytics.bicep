param location string

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-ddns-prod'
  location: location
  properties: {
    retentionInDays: 30
  }
}

output lawId string = law.id
