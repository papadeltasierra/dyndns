# Resource by Copilot
Given Copilot's design, I asked Copilot to produce a _"deployent recipe"_.

# Azure DDNS Service — Deployment Recipe

## 1. Resource groups and topology

### 1.1 Recommended resource groups (production)

- **`rg-ddns-core-prod`**
  Azure DNS, SQL Database, Key Vault, Managed Identities, API Management.

- **`rg-ddns-app-prod`**
  App Service (API + Portal), AKS, Container Registry, Application Insights.

- **`rg-ddns-net-prod`**
  VNet, Subnets, NAT Gateway, Firewall (optional), Private Endpoints, Public IPs.

- **`rg-ddns-ops-prod`**
  Log Analytics, Dashboards, Alerts, Automation (optional).

Mirror these for `dev` and `test` with smaller SKUs.

---

## 2. Core DNS, data, identity, and secrets

### 2.1 Public DNS

- **Azure DNS zone:**
  `ddns.yourcompany.com`

- Delegate from registrar → Azure DNS name servers.
- All DDNS A/AAAA records will be created under this zone.

---

### 2.2 Data layer (configuration and tenancy)

- **Azure SQL logical server:**
  `ddnssql-prod` (zone redundant where supported).

- **Azure SQL Database:**
  `ddns-config-db`
  - Tier: `General Purpose` or `Serverless`.
  - 2–4 vCores to start.
  - Geo-replication via Failover Group (recommended).

#### Suggested schema

- `Customers`
- `Plans`
- `Domains`
- `UpdateCredentials`
- `AuditLogs`

---

### 2.3 Managed identities

Create **user-assigned managed identities**:

- `mi-ddns-api`
- `mi-ddns-portal`
- `mi-ddns-rfc2136-gw`

#### RBAC assignments

- **DNS zone contributor**
  - Assigned to `mi-ddns-api` and `mi-ddns-rfc2136-gw` on the DNS zone.

- **SQL database roles**
  - Use AAD authentication on the logical server.
  - Create contained users from external provider.
  - Assign `db_datareader`, `db_datawriter`, and any custom roles required.

- **Key Vault access**
  - Use Key Vault access policies or RBAC to grant `Get` and `List` on secrets to the identities that need them.

---

### 2.4 Secrets

- **Azure Key Vault:** `kv-ddns-prod`

Stores:

- TSIG keys (RFC 2136).
- API keys for HTTPS DDNS.
- Signing/encryption keys.

Use:

- **Key Vault references** in App Service.
- **Secret Store CSI driver** or Workload Identity for AKS.

---

## 3. Networking

### 3.1 VNet layout

- **VNet:** `vnet-ddns-prod` (e.g., `10.10.0.0/16`)

#### Subnets

- `snet-aks` — AKS node pools.
- `snet-appsvc-integration` — delegated to App Service for VNet integration.
- `snet-private-endpoints` — SQL, Key Vault, etc.
- `snet-firewall` — optional (for Azure Firewall).

---

### 3.2 Connectivity

- **Private endpoints:**
  - SQL Database.
  - Key Vault.

- **NAT Gateway:**
  - Attach to outbound subnets used by AKS and App Service integration to provide stable outbound IPs.

- **Public IPs:**
  - One for **API Management**.
  - One for **AKS Load Balancer** (RFC 2136 endpoint).

Optionally introduce Azure Firewall or WAF depending on compliance requirements.

---

## 4. Compute and application components

## 4.1 AKS for RFC 2136 gateway

- **Cluster:** `aks-ddns-prod`
  - System node pool: 2× `Standard_D2s_v5`.
  - User node pool: 2–3× `Standard_D4s_v5` (adjust for load).
  - Availability Zones enabled where supported.
  - Azure CNI for VNet integration.
  - OIDC issuer + Workload Identity enabled.

### Workload

- **Namespace:** `ddns`.

- **Deployment:** `rfc2136-gateway`
  - Container listening on UDP/TCP 53.
  - Stateless; configuration sourced from environment variables and Key Vault via CSI.

- **Service:** `rfc2136-lb`
  - Type: `LoadBalancer`.
  - Ports: 53/UDP, 53/TCP.
  - Public IP: `pip-ddns-rfc2136-prod`.

### Responsibilities

1. Receive RFC 2136 `UPDATE` messages.
2. Validate TSIG (or configured shared secret).
3. Resolve customer and domain from SQL via managed identity.
4. Update Azure DNS using REST/SDK and managed identity permissions.

---

## 4.2 App Service for API and portal

- **App Service Plan:** `asp-ddns-prod`
  - Linux.
  - `P1v3` or `P2v3`.
  - Zone redundant where region supports it.

### Web apps

- `app-ddns-api-prod` — backend API.
- `app-ddns-portal-prod` — frontend portal.

### Configuration

- **VNet integration** to `snet-appsvc-integration`.
- Assign user-assigned managed identities:
  - API → `mi-ddns-api`.
  - Portal → `mi-ddns-portal`.

- **Azure AD authentication:**
  - Multi-tenant app registrations.
  - Portal uses AAD sign-in and maps `tid` to `Customers`.
  - API is protected via APIM and/or Easy Auth with JWT validation.

### API responsibilities

- CRUD operations for customers and domains.
- Enforcement of plan limits (`Plans.maxDomains`).
- Issuing and rotating DDNS API keys (stored in Key Vault).
- Implementing Marketplace fulfillment callbacks (activate, change plan, suspend, cancel).

### Portal responsibilities

- Domain management UI (list/add/remove).
- Display of current plan and usage (domain count vs limit).
- Display of client configuration examples (RFC 2136, HTTPS, Azure-auth, etc.).

---

## 4.3 API Management

- **API Management instance:** `apim-ddns-prod`
  - SKU: `Standard v2` or `Premium` for production, `Developer` for dev/test.

### APIs

- `ddns-public-api`
  - For HTTPS-based DDNS updates and management.
- `ddns-marketplace-fulfillment`
  - For Marketplace subscription lifecycle (webhooks).

### Policies

- **JWT validation:**
  - For Azure AD–secured endpoints (Azure-auth DDNS).

- **API key validation:**
  - For clients unable to use AAD (e.g., routers/NAS).

- **Rate limiting and throttling:**
  - Protect from abuse or misconfiguration.

- **Optional IP filtering:**
  - Restrict admin/management endpoints.

Backend for both: `app-ddns-api-prod`.

---

## 5. Monitoring, logging, and reliability

### 5.1 Observability

- **Log Analytics workspace:** `law-ddns-prod`.

- **Application Insights:**
  - `appi-ddns-api-prod`.
  - `appi-ddns-portal-prod`.

Connect:

- AKS (Container Insights) → Log Analytics.
- App Service → Application Insights.
- API Management → Log Analytics / App Insights.

Log DDNS updates with who/what/when/IP in both the database (`AuditLogs`) and structured app logs.

---

### 5.2 Alerts

Create alert rules for:

- **AKS:**
  - Node not ready, pod crash loops, etc.

- **DNS update pipeline:**
  - High rate of Azure DNS API failures.

- **API:**
  - 5xx rate spikes.
  - Latency above threshold.

- **SQL:**
  - High CPU or DTU/vCore utilization.
  - Failover events.

- **APIM:**
  - Abnormal 4xx/5xx spikes on DDNS endpoints.

---

## 6. Marketplace integration

### 6.1 SaaS offer

- Create a **SaaS offer** in Partner Center.

- Define **plans**, for example:
  - `Free` → `maxDomains = 5`.
  - `Standard` → `maxDomains = 50`.
  - `Pro` → `maxDomains = 500`.

- **Landing page URL:**
  - Points to portal, e.g. `https://portal.ddns.yourcompany.com/landing`.

- **Fulfillment webhook URL:**
  - `https://api.ddns.yourcompany.com/api/marketplace/fulfillment`.

---

### 6.2 Fulfillment flow (API side)

Implement endpoints in the API app:

- `POST /api/marketplace/fulfillment/subscriptions`
  - Validates marketplace token.
  - Creates `Customer` row with `planId`, `subscriptionId`, tenant info.

- `PATCH /api/marketplace/fulfillment/subscriptions/{id}`
  - Handles plan changes, suspension, cancellation.
  - Updates `Customer.planId` and status.

Business logic then enforces `Plans.maxDomains` and other constraints.

---

## 7. Tiering and update methods

### 7.1 Tier enforcement

- `Plans` table maps to Marketplace plans.
- On domain creation:
  - Check `COUNT(Domains WHERE customerId = X AND status = 'Active') < Plans.maxDomains`.
- Version 0:
  - `Free` plan with `maxDomains = 5`.

Extendable with:

- `maxUpdatesPerDay`.
- `maxRecordsPerDomain`.
- Other monetizable limits.

---

### 7.2 Update methods

#### RFC 2136

- Implemented in the **AKS RFC 2136 gateway**.
- Uses TSIG/shared secret for authentication.
- Resolves customer + domain from SQL.
- Updates Azure DNS zone using managed identity.

#### Azure AD–based HTTPS updates

- Client acquires AAD token for the APIM/API app.
- Calls `POST /ddns/update` (through APIM).
- Token → customer mapping (based on `tid` / `oid` / app roles).
- API validates ownership and limits, then updates Azure DNS.

#### HTTPS + API key

- For non-AAD capable clients (routers, NAS, home gateways).
- API key per customer/domain stored in Key Vault.
- APIM validates key in header.
- API performs same domain and plan checks, then updates DNS.

---

## 8. Deployment approach

### 8.1 Infrastructure as Code

Use **Bicep** or **Terraform** with modular structure:

- `core`
  - DNS, SQL, Key Vault, Managed Identities.

- `network`
  - VNet, subnets, Private Endpoints, Public IPs, NAT Gateway.

- `aks`
  - AKS cluster, nodepools, add-ons (Insights, OIDC).

- `app`
  - App Service plan, Web Apps, API Management.

- `monitoring`
  - Log Analytics, Application Insights, alert rules.

---

### 8.2 CI/CD

Use **GitHub Actions** or **Azure DevOps** pipelines:

- **Build and push**:
  - Container images to Azure Container Registry (ACR) for the RFC 2136 gateway and any other containerized components.

- **Deploy to AKS**:
  - Using Helm, Kustomize, or Kubernetes manifests.

- **Deploy App Service**:
  - ZIP deploy, container-based deploy, or Azure Web Apps Deploy task.

- **Deploy infrastructure**:
  - Apply Bicep/Terraform templates per environment (dev/test/prod).

---
