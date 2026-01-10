# RFC2136 Gateway Deployment pipeline
Here’s a pure Markdown, production‑ready GitHub Actions pipeline that deploys the RFC2136 Gateway to AKS using your Helm chart.

It assumes:
- You already pushed the gateway image to ACR
-  You have a Helm chart at:
```bash
charts/rfc2136-gateway
```
- You use GitHub Environments (dev, stage, prod)
- You authenticate to Azure using AZURE_CREDENTIALS
- You authenticate to AKS using azure/aks-set-context

## Required GitHub Secrets (per environment)
|Secret|	Description|
|-|-|
|AZURE_CREDENTIALS|	JSON from az ad sp create-for-rbac --sdk-auth|
|AZURE_RG|	Resource group containing AKS|
|AZURE_AKS_NAME	AKS| cluster name|
|AZURE_ACR_NAME	ACR| name (no domain)|
|AZURE_RFC2136_LB_IP|	Static public IP for the RFC2136|