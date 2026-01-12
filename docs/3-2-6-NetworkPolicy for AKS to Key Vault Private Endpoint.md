# A NetworkPolicy for AKS → Key Vault (via private endpoint)
Below is a pure Markdown, production‑ready Kubernetes NetworkPolicy that allows only your AKS workloads (e.g., API, RFC2136 gateway, or any pod you choose) to reach Azure Key Vault via its Private Endpoint.

Because Key Vault is exposed inside the VNet through a Private Endpoint, it appears as a single IP address inside the Private Endpoint subnet (e.g., 10.10.3.5).

NetworkPolicies operate at layer 3/4, so we restrict traffic by destination IP + port 443.

> !!PDS: You can paste this directly into your Helm chart or Kubernetes manifests.

NetworkPolicy — Allow Only Specific Pods → Key Vault Private Endpoint
(Pure Markdown)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-pods-to-keyvault-private-endpoint
  namespace: ddns
spec:
  podSelector:
    matchLabels:
      allow-keyvault: "true"
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: <KEYVAULT_PRIVATE_ENDPOINT_IP>/32
      ports:
        - protocol: TCP
          port: 443
```

### How to Use This Policy
Replace <KEYVAULT_PRIVATE_ENDPOINT_IP>

Retrieve the Key Vault Private Endpoint IP:

```bash
az network private-endpoint show \
  -n pe-kv \
  -g <resource-group> \
  --query "customDnsConfigs[0].ipAddresses[0]"
```

```yaml
cidr: 10.10.3.5/32
```
Label any pod that should be allowed to access Key Vault

Example (API Deployment):

```yaml
metadata:
  labels:
    app: ddns-api
    allow-keyvault: "true"
```
Example (RFC2136 Gateway):
```yaml
metadata:
  labels:
    app: rfc2136-gateway
    allow-keyvault: "true"
```
Any pod without this label will be blocked from accessing Key Vault.

## Optional: Add a default egress deny for the namespace
If you want strict zero‑trust:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: ddns
spec:
  podSelector: {}
  policyTypes:
    - Egress
```