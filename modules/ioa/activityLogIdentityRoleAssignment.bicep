targetScope = 'managementGroup'

param activityLogIdentityId string
param activityLogIdentityPrincipalId string
param principalType string = 'ServicePrincipal'

param ReaderRoleId string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader

resource activityLogIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(activityLogIdentityId, ReaderRoleId, managementGroup().id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', ReaderRoleId)
    principalId: activityLogIdentityPrincipalId
    principalType: principalType
  }
}
