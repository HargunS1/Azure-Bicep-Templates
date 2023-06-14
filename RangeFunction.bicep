// RANGE FUNCTION 

param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for i in range(2,5): {
  
  name: 'hargun${i}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}]
  

