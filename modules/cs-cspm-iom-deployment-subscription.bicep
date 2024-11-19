targetScope = 'subscription'

/*
  This Bicep template deploys infrastructure to enable CrowdStrike 
  Indicator of Misconfiguration (IOM) assessment.

  Copyright (c) 2024 CrowdStrike, Inc.
*/

/* Parameters */
@description('Targetscope of the IOM integration.')
@allowed([
  'ManagementGroup'
  'Subscription'
])
param targetScope string = 'Subscription'

@description('Subscription Id of the default Azure Subscription.')
param defaultSubscriptionId string

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

@description('ID of the Application Registration in Entra ID.')
param azureClientId string

@description('Password/Secret of the Application Registration in Entra ID.')
@secure()
param azureClientSecret string

@description('Principal Id of the Application Registration in Entra ID.')
param azurePrincipalId string

@description('Type of the Azure account to integrate. Commercial or Government.')
@allowed([
  'commercial'
  'gov'
])
param azureAccountType string = 'commercial'

@description('Assign required permissions on Azure Default Subscription automatically.')
param assignAzureSubscriptionPermissions bool = true

@description('Location for the resources deployed in this solution.')
param location string = deployment().location

@description('Tags to be applied to all resources.')
param tags object = {
  'cstag-vendor': 'crowdstrike'
  'cstag-product': 'fcs'
  'cstag-purpose': 'ioa'
}

/* Variables */

/* Resources */
module azureSubscription 'iom/azureSubscription.bicep' = {
  name: '${deploymentNamePrefix}-azureSubscription-${deploymentNameSuffix}'
  scope: subscription(defaultSubscriptionId)
  params: {
    targetScope: targetScope
    resourceGroupName: resourceGroupName
    falconClientId: falconClientId
    falconClientSecret: falconClientSecret
    falconCloudRegion: falconCloudRegion
    azureClientId: azureClientId
    azureClientSecret: azureClientSecret
    azurePrincipalId: azurePrincipalId
    azureAccountType: azureAccountType
    assignAzureSubscriptionPermissions: assignAzureSubscriptionPermissions
    location: location
    tags: tags
  }
}
