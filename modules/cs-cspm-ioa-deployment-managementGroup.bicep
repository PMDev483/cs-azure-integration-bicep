targetScope = 'managementGroup'

/*
  This Bicep template creates and assigns an Azure Policy on Azure Management Group level,
  used to ensure that Activity Log data is forwarded to CrowdStrike for 
  Indicator of Attack (IOA) assessment.

  Copyright (c) 2024 CrowdStrike, Inc.
*/

/* Parameters */
@description('The location for the resources deployed in this solution.')
param location string = deployment().location

@description('ID of the Azure Management Group to integrate into Falcon CSPM.')
param managementGroupId string

@description('The prefix to be added to the deployment name.')
param deploymentNamePrefix string = 'cs-cspm-ioa'

@description('The suffix to be added to the deployment name.')
param deploymentNameSuffix string = utcNow()

@description('Event Hub Name.')
param eventHubName string = 'cs-eventhub-monitor-activity-logs'

@description('Event Hub Authorization Rule Id.')
param eventHubAuthorizationRuleId string

/* Resources */
module activityLog 'ioa/activityLog.bicep' = {
  name: '${deploymentNamePrefix}-activityLog-${deploymentNameSuffix}'
  scope: managementGroup(managementGroupId)
  params: {
    location: location
    eventHubName: eventHubName
    eventHubAuthorizationRuleId: eventHubAuthorizationRuleId
  }
}
