param dnsZoneName string

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01' = {
  name: dnsZoneName
  location: 'global'
}

output dnsZoneId string = dnsZone.id
output nameServers array = dnsZone.properties.nameServers
