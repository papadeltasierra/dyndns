# GitHub Environments and Secrets Layout

## GitHub Environments
Your GitHub repository should define three environments:
- dev
- stage
- prod

Each environment has its own Azure credentials, resource group, App Service names, and AKS cluster names.
This ensures isolation, safe promotion, and controlled approvals.

```bash
Repository Settings →
  Environments →
    dev
    stage
    prod
```

Recommended protection rules:

|Environment|Protection|Notes|
|-|-|-|
|dev|none|Fast iteration|
|stage|required reviewers|QA validation|
|prod|required reviewers + wait timer|Production safety|

## Secrets per Environment
Each environment gets its own secrets.
Below is the recommended layout.

### dev
```bash
AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
AZURE_RG
AZURE_LOCATION
AZURE_API_APP
AZURE_PORTAL_APP
AZURE_AKS_NAME
AZURE_ACR_NAME
```

Example values
|Secret|Example|
|-|-|
|AZURE_RG|	rg-ddns-dev|
|AZURE_API_APP|	app-ddns-api-dev|
|AZURE_PORTAL_APP|	app-ddns-portal-dev|
|AZURE_AKS_NAME|	aks-ddns-dev|
|AZURE_ACR_NAME|	ddnsacrdev|
---
### stage
```bash
AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
AZURE_RG
AZURE_LOCATION
AZURE_API_APP
AZURE_PORTAL_APP
AZURE_AKS_NAME
AZURE_ACR_NAME
```
Example values
|Secret|	Example|
|-|-|
|AZURE_RG|	rg-ddns-stage|
|AZURE_API_APP|	app-ddns-api-stage|
|AZURE_PORTAL_APP|	app-ddns-portal-stage|
|AZURE_AKS_NAME|	aks-ddns-stage|
|AZURE_ACR_NAME|	ddnsacrstg|

---
### prod
```bash
AZURE_CREDENTIALS
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
AZURE_RG
AZURE_LOCATION
AZURE_API_APP
AZURE_PORTAL_APP
AZURE_AKS_NAME
AZURE_ACR_NAME
```
Example values
|Secret|	Example|
|-|-|
|AZURE_RG|	rg-ddns-prod|
|AZURE_API_APP|	app-ddns-api-prod|
|AZURE_PORTAL_APP|	app-ddns-portal-prod|
|AZURE_AKS_NAME|	aks-ddns-prod|
|AZURE_ACR_NAME|	ddnsacrprod|

## Secret Details
Below is a description of each secret and why it exists.

#### AZURE_CREDENTIALS
Used by GitHub Actions to authenticate to Azure.

Generated via:
```bash
az ad sp create-for-rbac \
  --name "github-ddns" \
  --role contributor \
  --scopes /subscriptions/<subId> \
  --sdk-auth
```
Paste the JSON output into the secret.

#### AZURE_SUBSCRIPTION_ID
Your Azure subscription ID.

#### AZURE_TENANT_ID
Your Azure AD tenant ID.

#### AZURE_RG
The resource group for the environment:
- rg-ddns-dev
- rg-ddns-stage
- rg-ddns-prod

#### AZURE_LOCATION
Azure region, e.g.:
```bash
uksouth
westeurope
eastus
````
#### AZURE_API_APP
Name of the API App Service:
- app-ddns-api-dev
- app-ddns-api-stage
- app-ddns-api-prod

#### AZURE_PORTAL_APP
Name of the Portal App Service:
- app-ddns-portal-dev
- app-ddns-portal-stage
- app-ddns-portal-prod

#### AZURE_AKS_NAME
Name of the AKS cluster:
- aks-ddns-dev
- aks-ddns-stage
- aks-ddns-prod

#### AZURE_ACR_NAME
Name of the Azure Container Registry:
- ddnsacrdev
- ddnsacrstg
- ddnsacrprod

## Optional Secrets (if needed)
```bash
API_KEY_SALT
MARKETPLACE_WEBHOOK_SECRET
APPINSIGHTS_CONNECTION_STRING
SQL_CONNECTION_STRING_OVERRIDE
```

## Recommended GitHub Repository Structure
```bash
.github/
  workflows/
    ci-cd.yml
docs/
  environments.md   <-- this file
infra/
src/
tests/
```