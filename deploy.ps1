param (
#   [Parameter(Mandatory=$true)]
#   [string]$DeploymentName,

  [Parameter(Mandatory=$true)]
  [string]$ResourceGroupName,

  [Parameter()]
  [string]$Location = "westus",

  [Parameter()]
  [string]$SecurityGroupName = "mySecurityGroup"
)

# Check if resource group exists
$existingResourceGroup = az group show --name $ResourceGroupName --query name -o tsv

if (!$existingResourceGroup) {
  # Create resource group using Azure CLI
  az group create --name $ResourceGroupName --location $Location
}

# Check if AAD group exists
$group = az ad group show --group $SecurityGroupName --query id -o tsv

if (!$group) {
  # Create AAD group using Azure CLI
  $group = az ad group create --display-name $SecurityGroupName --mail-nickname $SecurityGroupName -o json

  # Fetch group objectId into a variable
  $groupId = $group | ConvertFrom-Json | Select-Object -ExpandProperty id
} else {
  # Fetch group objectId into a variable
  $groupId = $group
}

# Deploy Bicep template
$deploymentOutput = az deployment group create `
  --resource-group $ResourceGroupName `
  --template-file ./main.bicep `
  --parameters aadGroupId="$groupId" `
  -o json

# Get output variables
$webAppPrincipalId = $($deploymentOutput | ConvertFrom-Json).properties.outputs.webAppPrincipalId.value

# Add webAppPrincipalId to AAD group
# Unfortunately, there isn't a way to do this using Bicep yet
az ad group member add --group $SecurityGroupName --member-id $webAppPrincipalId
