param dockerImage string = 'stevenry/stringfetcher:latest'
param webAppName string = 'myWebApp-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param aadGroupId string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${webAppName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: 'S1'
    tier: 'Standard'
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
      healthCheckPath: '/'
    }
  }
}

resource autoScaleSettings 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: '${webAppName}-autoscalesettings'
  location: location
  properties: {
    profiles: [
      {
        name: 'Default'
        capacity: {
          minimum: '1'
          maximum: '3'
          default: '1'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricResourceUri: webApp.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 80
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
    targetResourceUri: webApp.id
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

// This will ensure that the web app can access the SQL database, and will add an environment variable 'AZURE_SQL_CONNECTIONSTRING' to the web app.
// This is somewhat of an abuse of this resource type, but serves the purpose of enabling communication between the WebApp and the SQL server.
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
