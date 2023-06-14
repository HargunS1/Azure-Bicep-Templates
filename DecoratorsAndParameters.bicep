@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'


@minLength(5)
@maxLength(24)
param solutionName string = 'toy${uniqueString(resourceGroup().id)}'

param appServicePlanInstanceCount int = 1

param appServicePlanSku  object = {
  name: 'F1'
  tier: 'Free'
}
param location string = resourceGroup().location

var appServicePlanName = '${environmentName}-${solutionName}-plan'
var appServiceAppName = '${environmentName}-${solutionName}'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appServicePlanInstanceCount

  }
}



resource appserviceapp 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceAppName
  location: location
  properties:{
    serverFarmId: appServicePlan.id
    httpsOnly: true

  }
}
