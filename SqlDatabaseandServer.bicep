param sqlservername string = 'sqlserver252550'
param location string = resourceGroup().location
var databaseName = '${sqlservername}/sample-db'
param virtualNetworkName string = 'vnet-1'
param subnet1Name string = 'subnet-1'
param privateEndpointName string = 'pendpoint1'
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'



@secure()
@description('Sql administrator login')
param sqladministratorlogin string

@secure()
@description('Sql administrator password secret')
param sqladministratorloginpassword string

param sqldatabsku object = {
   
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  
}

resource sqlserver 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: sqlservername
  location: location

  properties: {
    administratorLogin: sqladministratorlogin
    administratorLoginPassword: sqladministratorloginpassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

resource SQLAllConnectionsAllowed 'Microsoft.Sql/servers/firewallRules@2020-11-01-preview' = {
  name: 'AllConnectionsAllowed'
  parent: sqlserver
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource sqldatabase 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: databaseName
  location: location
  sku: {
    name: sqldatabsku.name
    tier: sqldatabsku.tier
    capacity: sqldatabsku.capacity
  }
  
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 104857600
    sampleName: 'AdventureWorksLT'
  }
  dependsOn: [
    sqlserver
  ]

  
} 


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: virtualNetwork
  name: subnet1Name
  properties: {
    addressPrefix: '10.1.0.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlserver.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    virtualNetwork
  ]
}
  
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}


resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}


