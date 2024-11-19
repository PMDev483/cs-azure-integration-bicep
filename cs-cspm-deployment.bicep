targetScope = 'managementGroup'

/*
  This Bicep template deploys CrowdStrike CSPM integration for 
  Indicator of Misconfiguration (IOM) and Indicator of Attack (IOA) assessment.

  Copyright (c) 2024 CrowdStrike, Inc.
*/

/* Parameters */
@description('Targetscope of the IOM integration.')
@allowed([
  'ManagementGroup'
  'Subscription'
])
param targetScope string = 'ManagementGroup'

@description('ID of the Azure Management Group to integrate into Falcon CSPM.')
param managementGroupId string

@description('Subscription Id of the default Azure Subscription.')
param defaultSubscriptionId string

@description('The prefix to be added to the deployment name.')
param deploymentNamePrefix string = 'cs-cspm'

@description('The suffix to be added to the deployment name.')
param deploymentNameSuffix string = utcNow()

@description('CID for the Falcon API.')
param falconCID string

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

@description('Assign required permissions Azure Management Group automatically.')
param assignAzureManagementGroupPermissions bool = true

@description('Location for the resources deployed in this solution.')
param location string = deployment().location

@description('Tags to be applied to all resources.')
param tags object = {
  'cstag-vendor': 'crowdstrike'
  'cstag-product': 'fcs'
  'cstag-purpose': 'ioa'
}

param deployIOM bool = true

param deployIOA bool = true

/* IOA-specific parameter */
@description('Enable Application Insights for additional logging of Function Apps.')
#disable-next-line no-unused-params
param enableAppInsights bool = false

@description('Deploy Activity Log Diagnostic Settings')
param deployActivityLogDiagnosticSettings bool = false

@description('Deploy Entra Log Diagnostic Settings')
param deployEntraLogDiagnosticSettings bool = false

/* Resources */
module iomManagementGroupDeployment 'modules/cs-cspm-iom-deployment-managementGroup.bicep' = if (deployIOM && targetScope == 'ManagementGroup') {
  name: '${deploymentNamePrefix}-iomManagementGroupDeployment-${deploymentNameSuffix}'
  scope: managementGroup(managementGroupId)
  params: {
    targetScope: targetScope
    managementGroupId: managementGroupId
    defaultSubscriptionId: defaultSubscriptionId
    falconClientId: falconClientId
    falconClientSecret: falconClientSecret
    falconCloudRegion: falconCloudRegion
    azureClientId: azureClientId
    azureClientSecret: azureClientSecret
    azurePrincipalId: azurePrincipalId
    azureAccountType: azureAccountType
    assignAzureSubscriptionPermissions: assignAzureSubscriptionPermissions
    assignAzureManagementGroupPermissions: assignAzureManagementGroupPermissions
    location: location
    tags: tags
  }
}

module iomSubscriptionDeployment 'modules/cs-cspm-iom-deployment-subscription.bicep' = if (deployIOM && targetScope == 'Subscription') {
  name: '${deploymentNamePrefix}-iomManagementGroupDeployment-${deploymentNameSuffix}'
  scope: subscription(defaultSubscriptionId)
  params: {
    targetScope: targetScope
    defaultSubscriptionId: defaultSubscriptionId
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

module ioaSubscriptionDeployment 'modules/cs-cspm-ioa-deployment-subscription.bicep' = if (deployIOA) {
  name: '${deploymentNamePrefix}-ioaDeployment-${deploymentNameSuffix}'
  scope: subscription(defaultSubscriptionId)
  params:{
    falconCID: falconCID
    falconClientId: falconClientId
    falconClientSecret: falconClientSecret
    falconCloudRegion: falconCloudRegion
    enableAppInsights: enableAppInsights
    deployActivityLogDiagnosticSettings: deployActivityLogDiagnosticSettings
    deployEntraLogDiagnosticSettings: deployEntraLogDiagnosticSettings
    location: location
    tags: tags
  }
}

module ioaManagementGroupDeployment 'modules/cs-cspm-ioa-deployment-managementGroup.bicep' = if (deployIOA && targetScope == 'ManagementGroup') {
  name: '${deploymentNamePrefix}-ioaManagementGroupDeployment-${deploymentNameSuffix}'
  scope: managementGroup(managementGroupId)
  params: {
    managementGroupId: managementGroupId
    eventHubName: ioaSubscriptionDeployment.outputs.activityLogEventHubName
    eventHubAuthorizationRuleId: ioaSubscriptionDeployment.outputs.eventHubAuthorizationRuleId
    location: location
  }
}
