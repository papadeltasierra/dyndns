# NetworkPolicy — Allow Only APIM → API

> !!PDS: How do I use this?  Where?

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-apim-to-api
  namespace: ddns
spec:
  podSelector:
    matchLabels:
      app: ddns-api
  policyTypes:
    - Ingress
  ingress:
    - from:
        # Allow traffic from APIM's static outbound IP(s)
        - ipBlock:
            cidr: <APIM_OUTBOUND_IP>/32
      ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443
```
## How to Use This Policy
Replace <APIM_OUTBOUND_IP>

Use the outbound public IP of your APIM instance.
You can retrieve it with:

```bash
az apim show -n <apim-name> -g <resource-group> --query "publicIpAddresses"
```
If APIM has multiple outbound IPs, add them like this:
```yaml
ingress:
  - from:
      - ipBlock:
          cidr: 20.50.10.10/32
      - ipBlock:
          cidr: 20.50.10.11/32
```
## Optional: Deny all other ingress

If you want to harden the namespace further, add a default deny:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: ddns
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```