# NetworkPolicy restricting access to port 53
Here’s a pure Markdown, production‑ready Kubernetes NetworkPolicy that restricts access to port 53 (TCP + UDP) for your RFC2136 Gateway running in AKS.

This policy ensures:
- Only authorized pods (e.g., your API, internal services, or monitoring agents) can send RFC2136 traffic to the gateway.
- All other pod‑to‑pod traffic on port 53 is blocked.
- Both TCP and UDP are enforced (RFC2136 uses both).

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: rfc2136-gateway-restrict-port53
  namespace: ddns
spec:
  podSelector:
    matchLabels:
      app: rfc2136-gateway
  policyTypes:
    - Ingress
  ingress:
    - from:
        # Allow traffic only from pods with this label
        - podSelector:
            matchLabels:
              allow-rfc2136: "true"
      ports:
        - protocol: TCP
          port: 53
        - protocol: UDP
          port: 53
```

You can drop this directly into your Helm chart or apply it standalone.

## How to Use This Policy
Label any pod that should be allowed to send RFC2136 updates:
```yaml
metadata:
  labels:
    allow-rfc2136: "true"
```

> !!PDS: How/where do we use this?

Examples:
- Your RFC2136 test client
- Internal DNS update agents
- Monitoring or health‑check pods

All other pods in the namespace will be blocked from accessing port 53 on the gateway.

## Optional: Namespace‑wide default deny
If you want to harden the namespace further, add this:

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
This ensures no pod can receive traffic unless explicitly allowed by another NetworkPolicy.