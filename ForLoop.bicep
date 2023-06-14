// FOR LOOP DEMONSTRATION IF WE WANT TO RUN MULTIPLE STORAGE ACCOUNTS NAME


@description ('A List Of Names Of Storage Account To Be Create')
param storageaccountname array = [
  'storagehargun1'
  'storagebhangu1'
  'storagesingh1'
]

param location string = resourceGroup().location

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for storageaccountname in storageaccountname: {

  name: storageaccountname
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}]



