param location string = 'westus3'
param storageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string
param appServices array = [
  {
    name: 'appservice1'
    env: 'dev'
  }
  {
    name: 'appservice2'
    env: 'prod'
  }
]

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var auditingEnabled = environmentType == 'production'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (auditingEnabled) {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module appServiceResources './modules/appservice.bicep' = [ for appService in appServices: if (appService.env == 'production') {
  name: appService.name
  params: {
    location: location
    appServiceAppName: appServiceAppName
    environmentType: environmentType
  }
}]

output hostNames array = [ for i in range(0, length(appServices)) : appServiceResources[i].name  ]
