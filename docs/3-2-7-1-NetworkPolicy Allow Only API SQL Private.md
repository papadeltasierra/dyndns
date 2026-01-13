# NetworkPolicy — Allow Only API → SQL Private Endpoint

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-sql-private-endpoint
  namespace: ddns
spec:
  podSelector:
    matchLabels:
      app: ddns-api
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: <SQL_PRIVATE_ENDPOINT_IP>/32
      ports:
        - protocol: TCP
          port: 1433
```

## How to Use This Policy
Replace <SQL_PRIVATE_ENDPOINT_IP>

You can retrieve the SQL Private Endpoint IP using:

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
What This Policy Does
- Allows the API pods (app: ddns-api) to send traffic to:
  - The SQL Private Endpoint IP
  - On port 1433 (SQL)
- Blocks all other egress from the API pods to SQL
- Prevents any other pods in the namespace from reaching SQL

This is the correct zero‑trust pattern for AKS + SQL Private Endpoint.

## Optional: Add a default egress deny
If you want to fully lock down the namespace:

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