# KeyVault Design
Let’s build a clean, secure, Azure‑native Key Vault design tailored specifically for your DDNS SaaS platform. This design aligns with Azure best practices, supports multi‑tenant isolation, and integrates smoothly with your App Service, SQL deployment pipeline, and DDNS gateway.

I’ll break it down into:
- What secrets you need
- How to structure the vault
- Access control model
- Naming conventions
- Rotation policies
- Integration with your CI/CD and runtime services
- Optional multi‑tenant isolation patterns

And I’ll sprinkle in a few inline exploration links so you can dive deeper into any part you want.

## Azure Key Vault Design for the DDNS SaaS Platform
### Purpose of the vault
The vault stores all sensitive material used by the DDNS gateway and management portal, including:
- RFC 2136 shared secrets
- HTTPS API keys
- Azure‑auth client secrets (if you issue them)
- SQL connection strings (optional)
- Internal service credentials
- Signing keys for JWT or webhook validation
- Marketplace webhook secrets

The SQL database stores only references to secrets, never the secrets themselves.

## Vault Structure
A single vault is sufficient for v0, but structured so you can scale to multi‑region or multi‑tenant later.

## Vault name
```bash
kv-ddns-prod-001
```

## Secret categories
Organize secrets using prefixes to keep things tidy and enforce consistent lookup patterns.

|Category|	Prefix|	Purpose|
|-|-|-|
|RFC 2136 keys|	rfc2136--|	TSIG‑like shared secrets|
|HTTPS API keys|	apikey--|	Non‑AAD update method|
|Azure‑auth client secrets|	aadclient--|	Optional: if you issue client ||credentials|
|Internal service secrets|	svc-*|	App Service identity, webhook signing ||keys|
|SQL connection strings|	sql-*|	Optional: if not using managed identity|
|Marketplace secrets|	marketplace-*|	SaaS fulfillment webhook signing key|
Each secret is stored as a Key Vault Secret, not a Key or Certificate.

### Example secret layout
```bash
kv-ddns-prod-001
 ├── rfc2136-tenant123-home.example.net
 ├── rfc2136-tenant123-vpn.example.net
 ├── apikey-tenant123-home.example.net
 ├── apikey-tenant456-office.example.net
 ├── aadclient-tenant123-ddns-updater
 ├── svc-ddns-jwt-signing-key
 ├── svc-marketplace-webhook-secret
 └── sql-ddns-connectionstring   (optional)
 ```
Every secret is referenced in SQL by its Key Vault URI, e.g.:

```bash
https://kv-ddns-prod-001.vault.azure.net/secrets/rfc2136-tenant123-home.example.net
```
## Access Control Model
Use Azure RBAC (not access policies) for modern, scalable control.

### Principals
| Principal|	Permissions|	Purpose|
|-|-|-|
| App Service (DDNS Gateway)|	Key Vault Secrets User|	Read RFC2136 keys, |API | keys, JWT signing keys|
| App Service (Portal)|	Key Vault Secrets User|	Read/write tenant credentials|
| GitHub Actions SP|	Key Vault Secrets Officer|	Create/update secrets |during | deployment|
| Ops/Admin group|	Key Vault Administrator|	Full control|
### Why RBAC?
- Works with managed identities
- Easier to audit
- Scales better for multi‑tenant SaaS

## Secret Rotation Strategy
> When do theses happpen? what triggers them?
### RFC 2136 keys
- Rotated manually or via portal UI
- Versioned automatically by Key Vault
- Old versions kept until revoked

### API keys
- Rotated by tenant via portal
- Portal writes new secret → updates SQL reference

### Internal service keys
- JWT signing keys rotated every 90 days
- Marketplace webhook secret rotated every 180 days

### SQL connection string
- Avoid storing if using managed identity
- If stored, rotate every 180 days

## Integration with your system
## 1. DDNS Gateway
- Reads RFC2136 keys and API keys at runtime
- Caches them in memory for performance
- Uses Key Vault references in App Service configuration

### 2. Management Portal
- Creates secrets when tenants generate new credentials
- Stores only the URI in SQL
- Never logs or stores secret values

### 3. CI/CD
- GitHub Actions uses a service principal with limited rights
- Deployment scripts create/update internal secrets
- No secrets stored in the repo

### 4. SQL Database
- Stores only:
  - SecretRef (Key Vault URI)
  - Metadata (name, type, tenant, zone)

Never stores secret values

## Optional: Multi‑tenant isolation patterns
If you want stronger isolation later:

### Option A — One vault per tenant
```bash
kv-ddns-tenant123
kv-ddns-tenant456
```
Pros: strong isolation
Cons: more ops overhead

### Option B — One vault per region
```bash
kv-ddns-eu-prod
kv-ddns-us-prod
```
Pros: geo‑scaling
Cons: cross‑region complexity

### Option C — Single vault with strict RBAC (recommended for v0)

Simple, secure, scalable.

## Summary Table
|Component|	Stored in Key Vault|	Example|
|-|-|-|
|RFC 2136 secrets|	Yes|	rfc2136-tenant123-home.example.net|
|HTTPS API keys|	Yes|	apikey-tenant123-home.example.net|
|AAD client secrets|	Optional|	aadclient-tenant123-ddns-updater|
|SQL connection string|	Optional|	sql-ddns-connectionstring|
|JWT signing keys|	Yes|	svc-ddns-jwt-signing-key|
|Marketplace webhook secret|	Yes|	svc-marketplace-webhook-secret|