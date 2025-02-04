targetScope = 'subscription'

/*
  This Bicep template deploys Azure Activity Log Diagnostic Settings
  to existing Azure subscriptions in the current Entra Id tenant
  to enable CrowdStrike Indicator of Attack (IOA) assessment.

  Copyright (c) 2024 CrowdStrike, Inc.
*/

/* Parameters */
@minLength(36)
@maxLength(36)
@description('Subscription Id of the default Azure Subscription.')
param defaultSubscriptionId string

@description('The prefix to be added to the deployment name.')
param deploymentNamePrefix string = 'cs'

@description('The suffix to be added to the deployment name.')
param deploymentNameSuffix string = utcNow()

@description('Name of the resource group.')
param resourceGroupName string = 'cs-ioa-group' // DO NOT CHANGE

@description('Id of the user-assigned Managed Identity with Reader access to all Azure Subscriptions.')
param activityLogIdentityId string

@description('Event Hub Authorization Rule Id.')
param eventHubAuthorizationRuleId string

@description('Event Hub Name.')
param eventHubName string

/* Variables */
var scope = az.resourceGroup(resourceGroup.name)

/* Resource Deployment */
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' existing = {
  name: resourceGroupName
  scope: subscription(defaultSubscriptionId)
}

/* Get all enabled Azure subscriptions in the current Entra Id tenant */
module azureSubscriptions 'ioa/azureSubscriptions.bicep' = {
  name: '${deploymentNamePrefix}-ioa-azureSubscriptions-${deploymentNameSuffix}'
  scope: scope
  params: {
    activityLogIdentityId: activityLogIdentityId
  }
}

module activityLogDiagnosticSettings 'ioa/activityLogDiagnosticSettings.bicep' = {
  name: '${deploymentNamePrefix}-ioa-activityLogDiagnosticSettings-${deploymentNameSuffix}'
  scope: subscription(defaultSubscriptionId)
  params: {
    subscriptionIds: azureSubscriptions.outputs.activeAzureSubscriptions
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
    eventHubName: eventHubName
  }
}
