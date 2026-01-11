@description('Name of the Azure Container Registry')
param acrName string

@description('Location for the ACR')
param location string = resourceGroup().location

@description('SKU for the ACR: Basic, Standard, Premium')
param sku string = 'Premium'

@description('Enable admin user (not recommended for production)')
param adminUserEnabled bool = false

@description('Allow public network access')
param publicNetworkAccess string = 'Enabled' // or 'Disabled'

@description('Tags to apply to the ACR resource')
param tags object = {
  project: 'ddns-saas'
  environment: 'prod'
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: {
      defaultAction: 'Allow'
    }
  }
  tags: tags
}

output acrLoginServer string = acr.properties.loginServer
output acrResourceId string = acr.id
output acrIdentityPrincipalId string = acr.identity.principalId
