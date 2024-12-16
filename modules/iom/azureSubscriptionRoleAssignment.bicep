targetScope = 'subscription'

@description('Principal Id of the Application Registration in Entra ID.')
param azurePrincipalId string

@description('Type of the Principal. Defaults to ServicePrincipal.')
param azurePrincipalType string = 'ServicePrincipal'

param roleName string = 'cs-website-reader'
param roleDescription string = 'Crowdstrike Web App Service Custom Role'
param roleType string = 'CustomRole'

var roleDefinitionIds = [
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
  '21090545-7ca7-4776-b22c-e363652d74d2' // Key Vault Reader
  '7f6c6a51-bcf8-42ba-9220-52d62157d7db' // Azure Kubernetes Service RBAC Reader
]

var roleActions = [
    'Microsoft.Web/sites/Read'
    'Microsoft.Web/sites/config/Read'
    'Microsoft.Web/sites/config/list/Action'
    ]


resource WebsiteReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(roleName)
  properties: {
    assignableScopes: [subscription().id]
    description: roleDescription
    permissions: [
      {
        actions: roleActions
        notActions: []
      }
    ]
    roleName: roleName
    type: roleType
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleDefinitionId in roleDefinitionIds: {
    name: guid(azurePrincipalId, roleDefinitionId, subscription().id)
    properties: {
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
      principalId: azurePrincipalId
      principalType: azurePrincipalType
    }
  }
]

resource customRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
    name: guid(azurePrincipalId, WebsiteReaderRoleDefinition.id, subscription().id)
    properties: {
      roleDefinitionId:  WebsiteReaderRoleDefinition.id
      principalId: azurePrincipalId
      principalType: azurePrincipalType
    }
}
