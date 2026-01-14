# A NetworkPolicy restricting API egress to only APIM + SQL

Here’s a pure Markdown, production‑ready Kubernetes NetworkPolicy that restricts API pod egress so it can only talk to:

APIM (via its outbound IPs)

SQL Private Endpoint (via its private IP)

Everything else is blocked.

This is the correct zero‑trust pattern for AKS when your API must only call APIM and SQL.

## NetworkPolicy — Restrict API Egress to Only APIM + SQL
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-api-egress-to-apim-and-sql
  namespace: ddns
spec:
  podSelector:
    matchLabels:
      app: ddns-api
  policyTypes:
    - Egress
  egress:
    # Allow egress to APIM outbound IP(s)
    - to:
        - ipBlock:
            cidr: <APIM_OUTBOUND_IP_1>/32
        # Add more if APIM has multiple outbound IPs
        # - ipBlock:
        #     cidr: <APIM_OUTBOUND_IP_2>/32
      ports:
        - protocol: TCP
          port: 443

    # Allow egress to SQL Private Endpoint
    - to:
        - ipBlock:
            cidr: <SQL_PRIVATE_ENDPOINT_IP>/32
      ports:
        - protocol: TCP
          port: 1433
```
## How to Use This Policy
Replace <APIM_OUTBOUND_IP_1>

Get APIM outbound IPs:

```bash
az apim show -n <apim-name> -g <resource-group> --query "publicIpAddresses"
```
Example:
```yaml
cidr: 20.50.10.10/32
```
If APIM has multiple outbound IPs, add them as additional ipBlock entries.

Replace <SQL_PRIVATE_ENDPOINT_IP>

Get the SQL Private Endpoint IP:

> !!PDS: can we automate this?

```bash
az network private-endpoint show \
  -n pe-sql \
  -g <resource-group> \
  --query "customDnsConfigs[0].ipAddresses[0]"
```
Example:

```yaml
cidr: 10.10.3.4/32
```

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