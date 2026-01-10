Mermaid Diagram — Enforcement Layers for AKS Security

Below is a pure Markdown, clean Mermaid diagram that visualizes the enforcement layers protecting your AKS‑based DDNS platform:
- Pod Security Standards (PSS)
- NetworkPolicies
- Azure Private Endpoints
- Managed Identity + RBAC
- AppArmor/Seccomp
- Namespace isolation

It’s designed to be readable, accurate, and ready to paste into documentation.

```mermaid
flowchart TD

    subgraph User["Client / External Systems"]
        C1["APIM"]
        C2["RFC2136 Clients"]
    end

    subgraph Cluster["AKS Cluster (ddns namespace)"]

        subgraph PSS["Pod Security Standards (Restricted)"]
            API["ddns-api Pod"]
            GW["rfc2136-gateway Pod"]
            PORTAL["ddns-portal Pod"]
        end

        subgraph NP["NetworkPolicies"]
            NP1["Ingress: Only APIM → API"]
            NP2["Egress: Only API → SQL PE"]
            NP3["Egress: Only API → Key Vault PE"]
            NP4["Ingress: Only allowed pods → RFC2136 Gateway"]
        end

        subgraph Runtime["Runtime Hardening"]
            SC1["Seccomp: RuntimeDefault"]
            SC2["AppArmor: Hardened Profile"]
            SC3["Non-root User"]
            SC4["Drop ALL Capabilities"]
            SC5["Read-only Root FS"]
        end
    end

    subgraph Azure["Azure Platform"]
        SQL["SQL Private Endpoint"]
        KV["Key Vault Private Endpoint"]
        DNS["Azure DNS"]
        MI["Managed Identity + RBAC"]
    end

    %% Traffic flows
    C1 -->|HTTPS 443| NP1
    NP1 --> API

    API -->|TCP 1433| NP2 --> SQL
    API -->|HTTPS 443| NP3 --> KV

    C2 -->|RFC2136 TCP/UDP 53| NP4 --> GW

    API -->|Azure SDK| MI
    GW -->|Azure SDK| MI
    API --> DNS
    GW --> DNS

    %% Enforcement layering
    PSS --> NP
    NP --> Runtime
    Runtime --> Azure
```

## What This Diagram Shows
1. Pod Security Standards (Restricted)
- Non‑root
- No privilege escalation
- Drop all capabilities
- Seccomp + AppArmor
- Read‑only root filesystem
2. NetworkPolicies
- Only APIM can reach the API
- API can only reach SQL + Key Vault
- Only labeled pods can reach the RFC2136 gateway
- Everything else is denied
3. Runtime Hardening
- Seccomp: RuntimeDefault
- AppArmor: hardened profile
- No Linux capabilities
- Immutable filesystem
4. Azure Enforcement
- SQL + Key Vault only reachable via Private Endpoints
- DNS updates require Managed Identity
- RBAC controls all Azure operations