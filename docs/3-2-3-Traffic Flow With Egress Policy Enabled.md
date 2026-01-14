# Mermaid Diagram — Traffic Flow With Egress Policy Enabled

Here’s a pure Markdown, clean Mermaid diagram that shows the full traffic flow with the “API egress restricted to only APIM + SQL” NetworkPolicy enabled.
It visualizes what is allowed, what is blocked, and how the SQL Private Endpoint and APIM outbound IPs fit into the picture.

Mermaid Diagram — Traffic Flow With Egress Policy Enabled
```mermaid
flowchart LR

    %% --- AKS Namespace ---
    subgraph AKS["AKS Cluster (ddns namespace)"]
        API["ddns-api Pod<br/>(app: ddns-api)"]

        subgraph NP["NetworkPolicy: Restrict API Egress"]
            ALLOW1["Allow → APIM Outbound IP(s)<br/>TCP 443"]
            ALLOW2["Allow → SQL Private Endpoint<br/>TCP 1433"]
            DENY["Deny all other egress"]
        end
    end

    %% --- External Destinations ---
    subgraph APIM["Azure API Management"]
        APIMIP["APIM Outbound IP(s)"]
    end

    subgraph VNET["Azure VNet"]
        SQLPE["SQL Private Endpoint<br/>10.10.3.x"]
    end

    subgraph SQL["Azure SQL Database"]
        SQLDB["ddns-config-db"]
    end

    Internet["Internet"]
    OtherPods["Other Pods"]
    KV["Key Vault (unless separately allowed)"]
    External["External Services"]

    %% --- Allowed Paths ---
    API -->|TCP 443<br/>Allowed by ALLOW1| APIMIP
    API -->|TCP 1433<br/>Allowed by ALLOW2| SQLPE --> SQLDB

    %% --- Blocked Paths ---
    API -.->|Blocked by DENY| Internet
    API -.->|Blocked by DENY| OtherPods
    API -.->|Blocked by DENY| KV
    API -.->|Blocked by DENY| External
```
## What This Diagram Shows
Allowed traffic
- API → APIM outbound IPs on TCP 443<br/>
(for callbacks, token validation, or APIM‑initiated flows)
- API → SQL Private Endpoint on TCP 1433<br/>
(for database access)

Blocked traffic
- Any egress to the public internet
- Any egress to other pods
- Any egress to Key Vault unless a separate policy allows it
- Any egress to external services
- Any egress to non‑SQL private endpoints

This is exactly how the NetworkPolicy enforces zero‑trust egress for your API.