param dockerImage string = 'stevenry/stringfetcher:latest'
param webAppName string = 'myWebApp'
param location string = resourceGroup().location
param fqdn string = ''
param vnetName string = '${webAppName}-vnet'
param vnetAddressPrefix string = '10.0.0.0/16'
param subnet1Name string = 'subnet1'
param subnet1AddressPrefix string = '10.0.1.0/24'
param subnet2Name string = 'subnet2'
param subnet2AddressPrefix string = '10.0.2.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1AddressPrefix
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2AddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${webAppName}-plan'
  location: location
  kind: 'linux'
  sku: {
    name: 'P1v2'
    tier: 'PremiumV2'
  }
  properties:{
    reserved:true
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
    httpsOnly:true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerImage}'
      alwaysOn:true
      appSettings:[
        {
          name:'SQL_CONNECTION_STRING'
          value:'Server=tcp:${sqlServer.name}.database.windows.net;Database=${sqlDb.name};Authentication=Active Directory Integrated;'
        }
      ]
    }
    hostNameSslStates:[
      {
        name:fqdn != '' ? fqdn : '${webAppName}.azurewebsites.net'
        sslState:'SniEnabled'
        toUpdate:true
      }
    ]
  }
}

resource appServiceCertificate 'Microsoft.Web/certificates@2021-02-01' = {
  name:'${webAppName}-cert'
  location:location
  properties:{
    serverFarmId:appServicePlan.id
    canonicalName:fqdn != '' ? fqdn : '${webAppName}.azurewebsites.net'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name:'${webAppName}-sqlserver'
  location:location
  properties:{
    administratorLoginPassword:''
    publicNetworkAccess:'Disabled'
    version:'12.0'
    //azureADOnlyAuthentication:true
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: sqlServer
  name:'${webAppName}-sqldb'
  location:location
}

resource aadGroup 'Microsoft.AAD/groups@2020-10-01-preview' = {
  name:'${webAppName}-aadgroup'
}

resource aadGroupMember 'Microsoft.AAD/groups/members@2020-10-01-preview' = {
  parent: aadGroup
  name: '${webApp.identity.principalId}'
}

resource sqlAdmin 'Microsoft.Sql/servers/administrators@2021-03-01-preview' = {
  parent: sqlServer
  name:'ActiveDirectory'
  properties:{
    administratorType:'ActiveDirectory'
    login:aadGroup.properties.displayName
    sid:aadGroup.properties.objectId
    tenantId:aadGroup.properties.onPremisesSecurityIdentifier
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name:'${webAppName}-privateendpoint'
  location:location
  properties:{
    privateLinkServiceConnections:[
      {
        name:'${webAppName}-privatelinkserviceconnection'
        properties:{
          privateLinkServiceId:'/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Sql/servers/${sqlServer.name}'
          groupIds:[
            'sqlServer'
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections:[]
    subnet:{
      id:vnet.properties.subnets[1].id
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name:'privatelink.database.windows.net'
  location:'global'
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
  parent: privateEndpoint
  name:'default'
  properties:{
    privateDnsZoneConfigs:[
      {
        name:'config1'
        properties:{
          privateDnsZoneId:privateDnsZone.id
        }
      }
    ]
  }
}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name:'${webAppName}-vpngateway'
  location:location
  properties:{
    ipConfigurations:[
      {
        name:'vnetGatewayConfig'
        properties:{
          privateIPAllocationMethod:'Dynamic'
          subnet:{
            id:vnet.properties.subnets[0].id
          }
        }
      }
    ]
    gatewayType:'Vpn'
    vpnType:'RouteBased'
    sku:{
      name:'VpnGw1'
      tier:'VpnGw1'
    }
  }
}

resource vpnConnection 'Microsoft.Network/connections@2021-02-01' = {
  name:'${webAppName}-vpnconnection'
  location:location
  properties:{
    connectionType:'IPsec'
    sharedKey:'sharedkey1234'
    virtualNetworkGateway1:{
      id:vpnGateway.id
      properties: {}
    }
  }
}

resource webAppVnetConnection 'Microsoft.Web/sites/virtualNetworkConnections@2021-02-01' = {
  parent:webApp
  name:'primary'
  properties:{
    vnetResourceId:vnet.id
  }
}
