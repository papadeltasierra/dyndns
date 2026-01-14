param lawId string

resource alert 'Microsoft.Insights/metricAlerts@2023-01-01' = {
  name: 'alert-ddns-api-5xx'
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [lawId]
    criteria: {
      allOf: [
        {
          name: '5xx'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: 10
        }
      ]
    }
  }
}
