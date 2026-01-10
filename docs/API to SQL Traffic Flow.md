# Mermaid Diagram — API → SQL Traffic Flow (NetworkPolicy Enforced)

Below is a pure Markdown, clean Mermaid diagram that illustrates the API → SQL traffic flow with the NetworkPolicy restrictions enabled.

It shows exactly what is allowed, what is blocked, and how the SQL Private Endpoint fits into the path.

Mermaid Diagram — API → SQL Traffic Flow (NetworkPolicy Enforced)
```mermaid
flowchart LR

    subgraph AKS["AKS Cluster (ddns namespace)"]
        API["ddns-api Pod<br/>(app: ddns-api)"]

        subgraph NP["NetworkPolicy: Restrict API Egress"]
            RULE1["Allow → SQL Private Endpoint<br/>TCP 1433"]
            RULE2["Deny all other egress"]
        end
    end

    subgraph VNET["Azure VNet"]
        SQLPE["SQL Private Endpoint<br/>10.10.3.x"]
    end

    subgraph SQL["Azure SQL Database"]
        SQLDB["ddns-config-db"]
    end

    %% Allowed path
    API -->|TCP 1433<br/>Allowed by RULE1| SQLPE --> SQLDB

    %% Blocked paths
    API -.->|Blocked by RULE2| Internet
    API -.->|Blocked by RULE2| OtherPods["Other Pods"]
    API -.->|Blocked by RULE2| KV["Key Vault (unless separately allowed)"]
    API -.->|Blocked by RULE2| External["External Services"]
```
### What This Diagram Shows
Allowed:
- The API pod can reach only the SQL Private Endpoint on TCP 1433.
- SQL Private Endpoint forwards traffic to Azure SQL Database.

Blocked:
- Any egress to the public internet
- Any egress to other pods
- Any egress to Key Vault (unless a separate policy allows it)
- Any egress to arbitrary external services

This is the exact behavior enforced by the NetworkPolicy you defined.