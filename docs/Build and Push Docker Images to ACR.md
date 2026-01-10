# Build and Push Docker Images to ACR
## Required GitHub Secrets (per environment)
|Secret|	Description|
|-|-|
|AZURE_CREDENTIALS|	JSON from az ad sp create-for-rbac --sdk-auth|
|AZURE_ACR_NAME|	Name of your ACR (e.g., ddnsacrdev)|

What this pipeline does
- Logs into Azure using a federated identity or service principal
- Logs into ACR
- Builds Docker images for:
  - Ddns.Api
  - Ddns.Portal
- Tags them as:
  - youracr.azurecr.io/ddns-api:latest
  - youracr.azurecr.io/ddns-portal:latest
- Pushes both images to ACR