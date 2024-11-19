targetScope = 'subscription'

@description('Targetscope of the IOM integration.')
@allowed([
  'ManagementGroup'
  'Subscription'
])
param targetScope string

@description('The prefix to be added to the deployment name.')
param deploymentNamePrefix string = 'cs-cspm-iom'

@description('The suffix to be added to the deployment name.')
param deploymentNameSuffix string = utcNow()

@description('Name of the resource group.')
param resourceGroupName string = 'cs-iom-group' // DO NOT CHANGE

@description('Client ID for the Falcon API.')
param falconClientId string

@description('Client secret for the Falcon API.')
@secure()
param falconClientSecret string

@description('Falcon cloud region.')
@allowed([
  'US-1'
  'US-2'
  'EU-1'
])
param falconCloudRegion string = 'US-1'

@description('Id of the Application Registration in Entra ID.')
param azureClientId string

@description('Password/Secret of the Application Registration in Entra ID.')
@secure()
param azureClientSecret string

@description('Principal Id of the Application Registration in Entra ID.')
param azurePrincipalId string

@description('Type of the Principal, defaults to ServicePrincipal.')
param azurePrincipalType string = 'ServicePrincipal'

@description('Type of the Azure account to integrate. Commercial or Government.')
param azureAccountType string = 'commercial'

@description('Assign required permissions automatically.')
param assignAzureSubscriptionPermissions bool = true

@description('Location for the resources deployed in this solution.')
param location string = deployment().location

@description('Tags to be applied to all resources.')
param tags object = {}

/* Variables */
var roleDefinitionIds = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
  '21090545-7ca7-4776-b22c-e363652d74d2' // Key Vault Reader
  '7f6c6a51-bcf8-42ba-9220-52d62157d7db' // Azure Kubernetes Service RBAC Reader
  'de139f84-1756-47ae-9be6-808fbbe84772' // Website Contributor
]

/* Create Azure Resource Group for IOM resources */
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

/* Integrate Azure account into Falcon */
module azureAccount 'azureAccount.bicep' = {
  name: '${deploymentNamePrefix}-azureAccount-${deploymentNameSuffix}'
  scope: resourceGroup
  params: {
    falconClientId: falconClientId
    falconClientSecret: falconClientSecret
    falconCloudRegion: falconCloudRegion
    azureClientId: azureClientId
    azureClientSecret: azureClientSecret
    azureAccountType: azureAccountType
    targetScope: targetScope
  }
}

/* Assign required permissions on Azure Subscription */
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleDefinitionId in roleDefinitionIds: if (assignAzureSubscriptionPermissions) {
    name: guid(azurePrincipalId, roleDefinitionId, subscription().id)
    properties: {
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
      principalId: azurePrincipalId
      principalType: azurePrincipalType
    }
  }
]
