param locations array = [
  'westus'
  'eastus'
  'eastus2'
]


resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for (location, i) in locations: {

  name: 'alpha121${i+1}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}]
