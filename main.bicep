param dockerImage string = 'stevenry/stringfetcher:latest'
param webAppName string = 'myWebApp-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param aadGroupId string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${webAppName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImage}'
      appSettings:[
        {
          name:'SQL_CONNECTION_STRING'
          value:'Server=tcp:${sqlServer.name}.database.windows.net;Database=${sqlDb.name};Authentication=Active Directory Integrated;'
        }
      ]
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: '${webAppName}-sqlserver'
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    version: '12.0'
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login:'myAadGroup'
      sid:aadGroupId
      tenantId:tenant().tenantId
    }
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: sqlServer
  name: '${webAppName}-sqldb'
  location: location
}

resource sqlConnection 'Microsoft.ServiceLinker/linkers@2022-11-01-preview' = {
  name: 'sqlconnection'
  scope: webApp
  properties: {
    clientType: 'dotnet'
    authInfo: {
      authType: 'systemAssignedIdentity'
    }
    targetService: {
      type: 'AzureResource'
      id: sqlDb.id
    }
  }
}

output webAppPrincipalId string = webApp.identity.principalId
