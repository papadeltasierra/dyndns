# DDNS System Authentication

```mermaid
sequenceDiagram
    autonumber

    participant Client as DDNS Client (Device/Router)
    participant Portal as Management Portal (App Service)
    participant Gateway as DDNS Gateway API
    participant Entra as Microsoft Entra ID
    participant KV as Azure Key Vault
    participant SQL as Azure SQL (Metadata Only)

    %% --- Portal Login Flow ---
    Portal->>Entra: OIDC Login Request
    Entra-->>Portal: ID Token + Access Token
    Portal->>SQL: Query tenant + plan + credential metadata
    Portal->>KV: Retrieve secret (e.g., API key, RFC2136 key)
    KV-->>Portal: Secret value
    Portal-->>Client: Credential provisioning (UI/API)

    %% --- RFC 2136 Update Flow ---
    Client->>Gateway: RFC 2136 UPDATE + TSIG-like key
    Gateway->>SQL: Lookup credential metadata
    Gateway->>KV: Fetch TSIG/shared secret
    KV-->>Gateway: Secret value
    Gateway->>Gateway: Validate TSIG signature
    Gateway->>SQL: Validate tenant + zone + quotas
    Gateway->>AzureDNS: Apply DNS record update
    AzureDNS-->>Gateway: Update result
    Gateway-->>Client: RFC 2136 response

    %% --- HTTPS API Key Update Flow ---
    Client->>Gateway: HTTPS POST /ddns/update + API Key
    Gateway->>SQL: Lookup API key metadata
    Gateway->>KV: Retrieve API key secret
    KV-->>Gateway: Secret value
    Gateway->>Gateway: Validate API key
    Gateway->>AzureDNS: Apply DNS update
    AzureDNS-->>Gateway: Result
    Gateway-->>Client: HTTP 200/400

    %% --- Azure Auth (AAD) Update Flow ---
    Client->>Entra: Request OAuth2 Token (Client Credential / Device Code)
    Entra-->>Client: Access Token (JWT)
    Client->>Gateway: HTTPS POST /ddns/update + Bearer Token
    Gateway->>Entra: Validate JWT (issuer, audience, signature)
    Entra-->>Gateway: Validation OK
    Gateway->>SQL: Resolve tenant + zone permissions
    Gateway->>AzureDNS: Apply DNS update
    AzureDNS-->>Gateway: Result
    Gateway-->>Client: HTTP 200/401/403
```

## What This Diagram Shows
- Multi‑path authentication: RFC 2136, API keys, and Azure‑auth coexist cleanly.
- Key Vault as the single source of truth: Secrets never live in SQL or code.
- Portal-driven credential provisioning: Users authenticate via Entra ID, then generate keys.
- Gateway as the enforcement point: All auth, quotas, and tenant checks happen here.
- Azure DNS as the authoritative backend: Gateway translates updates into Azure DNS operations.