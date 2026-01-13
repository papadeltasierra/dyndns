# Deployment Sequence Diagram

```mermaid
flowchart TB

    %% --- Groups / Boundaries ---
    subgraph ClientSide["Public Internet"]
        Client["DDNS Clients / Browsers"]
    end

    subgraph Edge["Azure Edge Network"]
        FD["Azure Front Door<br/>• Global entry point<br/>• WAF + TLS termination"]
    end

    subgraph AppLayer["App Service Layer"]
        AS_API["App Service: DDNS Gateway<br/>• RFC2136 handler<br/>• HTTPS API<br/>• Managed Identity"]
        AS_PORTAL["App Service: Management Portal<br/>• Tenant UI<br/>• Managed Identity"]
    end

    subgraph DataLayer["Data & Secrets Layer"]
        SQL["Azure SQL Database<br/>• Tenants, zones, metadata"]
        KV["Azure Key Vault<br/>• RFC2136 keys<br/>• API keys<br/>• JWT signing keys"]
    end

    subgraph BuildLayer["Build & Container Layer"]
        ACR["Azure Container Registry<br/>• Stores DDNS Gateway & Portal images"]
        GH["GitHub Actions<br/>• CI/CD pipelines<br/>• OIDC auth to Azure"]
    end

    %% --- Flows ---
    Client --> FD
    FD --> AS_API
    FD --> AS_PORTAL

    AS_API --> SQL
    AS_PORTAL --> SQL

    AS_API --> KV
    AS_PORTAL --> KV

    GH --> ACR
    GH --> AS_API
    GH --> AS_PORTAL

    ACR --> AS_API
    ACR --> AS_PORTAL

```

## What this diagram highlights
- Azure Front Door is the global, secure entry point for both the DDNS Gateway and the Portal.
- App Service hosts:
   - The DDNS Gateway (RFC 2136, HTTPS API, Azure‑auth)
   - The Management Portal (tenant UI, credential provisioning)
- Both App Services use Managed Identity to securely access:
   - Azure SQL for metadata
   - Key Vault for secrets
- ACR stores container images for both services.
- GitHub Actions builds, pushes, and deploys images using OIDC (no secrets).