param location string = resourceGroup().location
param name1 string = 'app${uniqueString(resourceGroup().id)}'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: name1
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

param name2 string = 'service${uniqueString(resourceGroup().id)}'

resource appserviceapp 'Microsoft.Web/sites@2022-09-01' = {
  name: name2
  location: location
  properties:{
    serverFarmId: appServicePlan.id
    httpsOnly: true

  }
}
