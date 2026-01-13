# Microsoft Marketplace Commercial SaaS Provisioning

```mermaid
sequenceDiagram
    autonumber

    participant Customer as Customer (Azure Portal)
    participant Marketplace as Microsoft Marketplace
    participant Landing as SaaS Landing Page<br/>(Your App Service)
    participant Backend as Provisioning Backend<br/>(Your API)
    participant SQL as Azure SQL<br/>(Tenants & Plans)

    %% --- Subscription Purchase ---
    Customer->>Marketplace: Select SaaS Offer + Plan
    Marketplace-->>Customer: Confirm purchase UI

    %% --- Marketplace Calls Landing Page ---
    Marketplace->>Landing: POST /landing<br/>?token=activationToken
    Landing->>Marketplace: Validate token
    Marketplace-->>Landing: Subscription details<br/>(subscriptionId, planId, tenantId)

    %% --- Tenant Registration ---
    Landing->>Customer: Prompt to sign in (Entra ID)
    Customer-->>Landing: ID Token + Access Token

    %% --- Backend Provisioning ---
    Landing->>Backend: Create tenant record<br/>(subscriptionId, planId, aadTenantId)
    Backend->>SQL: Insert Tenant + Plan + Status=Pending
    SQL-->>Backend: OK

    %% --- Activate Subscription ---
    Backend->>Marketplace: PATCH /subscriptions/{id}/activate
    Marketplace-->>Backend: Activation OK

    %% --- Finalize ---
    Backend->>SQL: Update Tenant Status=Active
    Landing-->>Customer: Subscription ready<br/>Open Management Portal

```

## What this diagram captures
- Azure Marketplace → Landing Page handshake using the activation token
- Customer authentication via Entra ID
- Backend provisioning of tenant, plan, and limits
- Marketplace activation callback
- Final tenant activation in your SQL database
- Smooth handoff to the management portal

This is the canonical flow Microsoft expects for SaaS offers, and it aligns perfectly with the architecture you’re building.