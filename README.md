![CrowdStrike Falcon](https://raw.githubusercontent.com/CrowdStrike/falconpy/main/docs/asset/cs-logo.png)

# Falcon CSPM Registration with Azure Bicep

The Azure Bicep templates provided in this repository allow for an easy and seamless integration of Azure environments into CrowdStrike Falcon Cloud Security.

## Deployment using Azure CLI

### Create Application Registration (Optional)

The command below creates a new app registration in Entra ID, including the required Microsoft Graph API permissions. This command needs to be executed by a user having the following Entra ID roles:
- ***Application Developer***, ***Cloud Application Administrator*** or ***Application Administrator*** - to create the app registration in Microsoft Entra ID
- ***Privileged Role Administrator*** or ***Global Administrator*** - to provide administrative consent to the requested Microsoft Graph API permissions.

> [!NOTE]
> Use the optional *grantAdminConsent* parameter to disable granting administrative consent to the requested Microsoft Graph API permissions automatically.

#### Deployment command

```sh
az deployment sub create --name 'cs-cspm-appregistration' --location westeurope \
  --template-file modules/iom/azureAppRegistration.bicep \
  --only-show-errors
```

#### Parameters

| Parameter name | Required | Description |
| --- | --- | --- |
| applicationName | no | Name of the App registration in Entra ID. Defaults to **CrowdStrikeCSPM-${uniqueString}**, e.g. **CrowdStrikeCSPM-2452hzjqllbqm** |
| publicCertificate | no | Base64-encoded string of the public certificate raw data. Default is **empty**. This certificate is used to connect from the Falcon platform to Azure. |
| grantAdminConsent | no | Provide admin consent to Microsoft Graph API permissions automatically. Defaults to **true**. Requires ***Privileged Role Administrator*** or ***Global Administrator*** permissions in Entra ID. |

### Registration of a single Azure Subscription
The command below registers a single Azure Subscription into CrowdStrike Falcon Cloud Security by performing the following actions:

- Creates an app registration in Microsoft Entra ID, including Microsoft Graph API permissions and administrative consent
- Creates Microsoft Azure activity log diagnostic setting
- Creates Microsoft Entra ID diagnostic setting
- Assigns the following Azure RBAC permissions on the Azure Subscription
  - *Reader*
  - *Security Reader*
  - *Key Vault Reader*
  - *Azure Kubernetes Service RBAC Reader*
- Assigns the *cs-website-reader* custom role on the Subscription with the following actions
  - *Microsoft.Web/sites/Read*
  - *Microsoft.Web/sites/config/Read*
  - *Microsoft.Web/sites/config/list/Action*
- Deploys infrastructure for Indicator of Attack (IOA) assessment
- Integrates the Subscription into the CrowdStrike Falcon Cloud Security for Indicator of Misconfiguration (IOM) and Indicator of Attack (IOA) assessment

#### Required permissions

- ***Application Developer***, ***Cloud Application Administrator*** or ***Application Administrator*** role in Microsoft Entra ID - to create the app registration in Microsoft Entra ID
- ***Privileged Role Administrator*** or ***Global Administrator*** role in Microsoft Entra ID - to provide administrative consent to the requested Microsoft Graph API permissions.
  
> [!NOTE]
> Use the optional *grantAdminConsent* parameter to disable granting administrative consent to the requested Microsoft Graph API permissions automatically.

- ***Owner*** role of the Azure subscription to be integrated into CrowdStrike Falcon Cloud Security

#### Deployment command

```sh
az deployment sub create --name 'cs-cspm-subscription-deployment' --location westeurope \
  --template-file cs-cspm-deployment-subscription.bicep \
  --only-show-errors
```

> [!NOTE]
> The deployment command can be executed multiple times to register additional Azure subscriptions into CrowdStrike Falcon Cloud Security.

#### Parameters

| Parameter name | Required | Description |
| --- | --- | --- |
| defaultSubscriptionId | yes | Subscription Id of the default Azure Subscription. |
| falconCID | yes | CID for the Falcon API. |
| falconClientId | yes | Client ID for the Falcon API. |
| falconClientSecret | yes | Client secret for the Falcon API. |
| falconCloudRegion | no | Falcon cloud region. Defaults to ***US-1***. Allowed values are US-1, US-2 or EU-1.|
| useExistingAppRegistration | no | Use an existing Application Registration. Defaults to ***false***. |
| grantAppRegistrationAdminConsent | no | Grant admin consent for Application Registration. Defaults to ***true***. |
| azureClientId | no | Application Id of an existing Application Registration in Entra ID. Only used with parameter *useExistingAppRegistration*. |
| azureClientSecret | no | Application Secret of an existing Application Registration in Entra ID. Only used with parameter *useExistingAppRegistration*. |
| azurePrincipalId | no | Principal Id of the Application Registration in Entra ID. Only used with parameter *useExistingAppRegistration*. |
| azureAccountType | no | Type of the Azure account to integrate. Defaults to ***commercial***. Allowed values are commercial or gov. |
| location | no | Location for the resources deployed in this solution. |
| tags | no | Tags to be applied to all resources. |
| deployIOM | no | Deploy Indicator of Misconfiguration (IOM) integration. Defaults to ***true***. |
| assignAzureSubscriptionPermissions | no | Assign required permissions on Azure Default Subscription automatically. Defaults to ***true***. |
| deployIOA | no | Deploy Indicator of Attack (IOA) integration. Defaults to ***true***. |
| enableAppInsights | no | Enable Application Insights for additional logging of Function Apps. Defaults to ***false***. |
| deployActivityLogDiagnosticSettings | no | Deploy Activity Log Diagnostic Settings. Defaults to ***true***. |
| deployEntraLogDiagnosticSettings | no | Deploy Entra Log Diagnostic Settings. Defaults to ***true***. |

### Registration of an Azure management group
The command below registers an Azure management group, including all Azure subscriptions, into CrowdStrike Falcon Cloud Security by performing the following actions:

- Creates an app registration in Microsoft Entra ID, including Microsoft Graph API permissions and administrative consent
- Assigns the following Azure RBAC permissions to the created app registration on the Azure management group
  - *Reader*
  - *Security Reader*
  - *Key Vault Reader*
  - *Azure Kubernetes Service RBAC Reader*
  - *Website Contributor*
- Assigns the *cs-website-reader* custom role on the Subscription with the following actions
  - *Microsoft.Web/sites/Read*
  - *Microsoft.Web/sites/config/Read*
  - *Microsoft.Web/sites/config/list/Action*
- Creates and Azure Policy definition and management group assignment to create Azure subscription diagnostic settings
- Creates Microsoft Entra ID diagnostic setting
- Deploys infrastructure for Indicator of Attack (IOA) assessment
- Integrates the Subscription into the CrowdStrike Falcon Cloud Security for Indicator of Misconfiguration (IOM) and Indicator of Attack (IOA) assessment

> [!IMPORTANT]
> Registration only supports the Azure root management group (Tenant root group).

#### Required permissions

- ***Application Developer***, ***Cloud Application Administrator*** or ***Application Administrator*** role in Microsoft Entra ID - to create the app registration in Microsoft Entra ID
- ***Privileged Role Administrator*** or ***Global Administrator*** role in Microsoft Entra ID - to provide administrative consent to the requested Microsoft Graph API permissions.
  
> [!NOTE]
> Use the optional *grantAdminConsent* parameter to disable granting administrative consent to the requested Microsoft Graph API permissions automatically.

- ***Owner*** role for the Azure management group to be integrated into CrowdStrike Falcon Cloud Security
- ***Owner*** role for the Azure subscription to be used for deployment of the infrastructure for Indicator of Attack (IOA) assessment

#### Deployment command

```sh
az deployment mg create --name 'cs-cspm-managementgroup-deployment' --location westeurope \
  --management-group-id $(az account show --query tenantId -o tsv) \
  --template-file cs-cspm-deployment-managementGroup.bicep \
  --only-show-errors
```

#### Parameters

| Parameter name | Required | Description |
| --- | --- | --- |
| defaultSubscriptionId | yes | Subscription Id of the default Azure Subscription. |
| falconCID | yes | CID for the Falcon API. |
| falconClientId | yes | Client ID for the Falcon API. |
| falconClientSecret | yes | Client secret for the Falcon API. |
| falconCloudRegion | no | Falcon cloud region. Defaults to ***US-1***. Allowed values are US-1, US-2 or EU-1.|
| useExistingAppRegistration | no | Use an existing Application Registration. Defaults to ***false***. |
| grantAppRegistrationAdminConsent | no | Grant admin consent for Application Registration. Defaults to ***true***. |
| azureClientId | no | Application Id of an existing Application Registration in Entra ID. Only used with parameter *useExistingAppRegistration*. |
| azureClientSecret | no | Application Secret of an existing Application Registration in Entra ID. Only used with parameter *useExistingAppRegistration*. |
| azurePrincipalId | no | Principal Id of the Application Registration in Entra ID. Only used with parameter *useExistingAppRegistration*. |
| azureAccountType | no | Type of the Azure account to integrate. Defaults to ***commercial***. Allowed values are commercial or gov. |
| location | no | Location for the resources deployed in this solution. |
| tags | no | Tags to be applied to all resources. |
| deployIOM | no | Deploy Indicator of Misconfiguration (IOM) integration. Defaults to ***true***. |
| assignAzureSubscriptionPermissions | no | Assign required permissions on Azure Default Subscription automatically. Defaults to ***false***. |
| assignAzureManagementGroupPermissions | no | Assign required permissions Azure Management Group automatically. Defaults to ***true***. |
| deployIOA | no | Deploy Indicator of Attack (IOA) integration. Defaults to ***true***. |
| enableAppInsights | no | Enable Application Insights for additional logging of Function Apps. Defaults to ***false***. |
| deployActivityLogDiagnosticSettings | no | Deploy Activity Log Diagnostic Settings. Defaults to ***true***. |
| deployEntraLogDiagnosticSettings | no | Deploy Entra Log Diagnostic Settings. Defaults to ***true***. |

## Examples

### Using existing app registration in Entra ID
> [!IMPORTANT]
> To use an existing app registration Application.ReadWrite.OwnedBy.

## Contributing

If you want to develop new content or improve on this collection, please open an issue or create a pull request. All contributions are welcome!

## Support

This is a community-driven, open source project aimed to register Falcon CSPM with Azure using Bicep. While not an official CrowdStrike product, this repository is maintained by CrowdStrike and supported in collaboration with the open source developer community.

For additional information, please refer to the [SUPPORT.md](https://github.com/CrowdStrike/azure-cspm-registration-bicep/main/SUPPORT.md) file.

## License Information

See the [LICENSE](https://github.com/CrowdStrike/azure-cspm-registration-bicep/main/LICENSE) for more information.
