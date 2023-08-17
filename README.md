# RandomStringDemo

Creates a set of infrastucture to host a simple app that returns a random string from a DB.

## Prerequisites

You must have the Azure CLI installed, and must have called `az login` to authenticate. Script assumes you have Owner access over the subscription.

## Deploying resources

Simply run the `deploy.ps1` script using PowerShell to deploy the assets, specifying a resource group to deploy into:

```powershell
./deploy.ps1 -ResourceGroupName <group>
```

The infrastructure will be deployed with a prebuilt image of the .NET application contained in this repository: `stevenry/stringfetcher:latest`

## TODOs

This repo was created with simplicity of deployment in mind. A "production ready" solution would need additional improvements such as:

* Deploy Web App and SQL server into a VNET and enable Private Links for DB communication. (Or otherwise refine the network strategies used as to not unnecessarily expose the DB)
* Parameters allowing customization of SKUs, scale settings, etc.
* Provide scripts, parameters, and infrastructure to enable building custom versions of the .NET application and host in a private Azure Container Registry.
    * Enables inner-loop development of the application
    * Increase organizational security by using private artifact hosts rather than public Docker Hub
* Allow specification of a real, custom DNS name rather than relying on the Azure-provided one. (With managed TLS certificate support.)
    * Add a traffic manager layer that would allow transparent routing and failover between regions.
* Depending on business need - introduce a scaling strategy for the DB layer. Options include:
    * Introduce regional, replicated failover groups for the SQL databases for regional resiliency.
    * Introduce caching layers such that the app needn't execute a real query on each request.
    * Transition to a more autoscale-friendly DB product such as CosmosDB.
* Depending on business requirements around data isolation, update the template such that re-use of infrastructure is possible when introducing new environments.
* Much, much more :)