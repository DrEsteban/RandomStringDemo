param dockerImage string
param webAppName string
param location string = resourceGroup().location
param fqdn string = ''

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${webAppName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImage}'
      alwaysOn: true
      httpsOnly: true
      appSettings:[
        {
          name:'SQL_CONNECTION_STRING'
          value:'Server=tcp:${sqlServer.name}.database.windows.net;Database=${sqlDb.name};Authentication=Active Directory Integrated;'
        }
      ]
    }
    hostNameSslStates: [
      {
        name: fqdn != '' ? fqdn : '${webAppName}.azurewebsites.net'
        sslState: 'SniEnabled'
        toUpdate: true
      }
    ]
  }
}

resource appServiceCertificate 'Microsoft.Web/certificates@2021-02-01' = {
  name: '${webAppName}-cert'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    canonicalName: fqdn != '' ? fqdn : '${webAppName}.azurewebsites.net'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-03-01-preview' = {
  name: '${webAppName}-sqlserver'
  location: location
  properties: {
    administratorLoginPassword: ''
    publicNetworkAccess: 'Enabled'
    version: '12.0'
    azureADOnlyAuthentication:true
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-03-01-preview' = {
  name: '${sqlServer.name}/${webAppName}-sqldb'
  location: location
}

resource aadGroup 'Microsoft.AAD/groups@2020-10-01-preview' = {
  name:'${webAppName}-aadgroup'
}

resource aadGroupMember 'Microsoft.AAD/groups/members@2020-10-01-preview' = {
  name:'${aadGroup.name}/${webApp.identity.principalId}'
}

resource sqlAdmin 'Microsoft.Sql/servers/administrators@2021-03-01-preview' = {
  name:'${sqlServer.name}/ActiveDirectory'
  properties:{
    administratorType:'ActiveDirectory'
    login:aadGroup.properties.displayName
    sid:aadGroup.properties.objectId
    tenantId:aadGroup.properties.onPremisesSecurityIdentifier
  }
}
