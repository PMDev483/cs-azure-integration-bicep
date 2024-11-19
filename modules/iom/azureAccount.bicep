param falconClientId string

@secure()
param falconClientSecret string

@allowed([
  'US-1'
  'US-2'
  'EU-1'
])
param falconCloudRegion string = 'US-1'

param azureClientId string

@secure()
param azureClientSecret string

param azureAccountType string = 'commercial'

@allowed([
  'ManagementGroup'
  'Subscription'
])
param targetScope string

param location string = resourceGroup().location

param tags object = {}

resource setAzureDefaultSubscription 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'cs-cspm-iom-${subscription().subscriptionId}'
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '12.3'
    environmentVariables: [
      {
        name: 'FALCON_CLOUD_REGION'
        value: falconCloudRegion
      }
      {
        name: 'FALCON_CLIENT_ID'
        value: falconClientId
      }
      {
        name: 'FALCON_CLIENT_SECRET'
        secureValue: falconClientSecret
      }
      {
        name: 'AZURE_CLIENT_ID'
        value: azureClientId
      }
      {
        name: 'AZURE_CLIENT_SECRET'
        secureValue: azureClientSecret
      }
    ]
    arguments: '-AzureAccountType ${azureAccountType} -AzureTenantId ${tenant().tenantId} -AzureSubscriptionId ${subscription().subscriptionId} -TargetScope ${targetScope}'
    scriptContent: loadTextContent('../../scripts/New-FalconCspmAzureAccount.ps1')
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
  }
}
