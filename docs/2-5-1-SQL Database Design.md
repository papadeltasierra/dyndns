# SQL Database Design

## 1. Design goals and principles
Goals:
- Support multi-tenant SaaS (many customers, one DB).
- Model subscription/plan, zones, records, credentials, and update logs.
- Enforce quotas (e.g., “max 5 zones” for v0).
- Keep secrets outside the DB (only references to Key Vault).
- Be easy to extend without breaking.

Key principles:
- Single DB, TenantId in every tenant-owned table (soft isolation).
- Use surrogate keys (INT IDENTITY or BIGINT IDENTITY / GUID) for internal - relationships.
- Use Key Vault for secret material (store only IDs/aliases in SQL).
- Soft-delete where useful; avoid physically deleting zones/records by default
  - But will need to purge periodically **and automatically** otherwise database grows forever.

## 2. Core tenancy and plans
### 2.1 Table: Tenants
Represents a customer (usually mapped to an Entra ID tenant + Marketplace subscription).

```sql
CREATE TABLE Tenants (
    TenantId            BIGINT IDENTITY(1,1) PRIMARY KEY,
    ExternalTenantId    NVARCHAR(64)  NOT NULL, -- e.g., Entra tenant ID or your own GUID
    DisplayName         NVARCHAR(256) NOT NULL,
    MarketplaceSubId    NVARCHAR(128) NULL,     -- SaaS subscription ID
    PlanId              INT           NOT NULL, -- FK to Plans
    Status              VARCHAR(32)   NOT NULL DEFAULT 'Active', -- Active, Suspended, Cancelled
    CreatedAtUtc        DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc        DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Tenants_ExternalTenant UNIQUE (ExternalTenantId),
    CONSTRAINT FK_Tenants_Plans FOREIGN KEY (PlanId) REFERENCES Plans (PlanId)
);
```
### 2.2 Table: Plans
Defines pricing tiers and limits (e.g., v0 “Basic” plan with 5 zones).

```sql
CREATE TABLE Plans (
    PlanId          INT IDENTITY(1,1) PRIMARY KEY,
    PlanName        NVARCHAR(100) NOT NULL, -- e.g., Basic, Standard, Pro
    Description     NVARCHAR(512) NULL,
    MaxZones        INT           NOT NULL, -- e.g., 5 for v0
    MaxRecordsPerZone INT         NOT NULL, -- can be large
    MaxRequestsPerDay INT         NOT NULL,
    IsDefault       BIT           NOT NULL DEFAULT 0,
    CreatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Plans_PlanName UNIQUE (PlanName)
);
```
## 3. Zones and records
### 3.1 Table: Zones
Each row represents a DNS zone/domain managed for a tenant. It corresponds to a zone in Azure DNS or a logical subset.

```sql
CREATE TABLE Zones (
    ZoneId          BIGINT IDENTITY(1,1) PRIMARY KEY,
    TenantId        BIGINT        NOT NULL,
    ZoneName        NVARCHAR(255) NOT NULL, -- FQDN, e.g., home.example.net
    AzureDnsZoneId  NVARCHAR(256) NULL,     -- optional: Azure resource ID or name
    Status          VARCHAR(32)   NOT NULL DEFAULT 'Active', -- Active, Pending, Disabled
    Description     NVARCHAR(512) NULL,
    CreatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted       BIT           NOT NULL DEFAULT 0,
    CONSTRAINT FK_Zones_Tenants FOREIGN KEY (TenantId) REFERENCES Tenants (TenantId),
    CONSTRAINT UQ_Zones_Tenant_ZoneName UNIQUE (TenantId, ZoneName)
);
```
### 3.2 Table: Records
Logical representation of DNS records. You can choose to mirror or cache Azure DNS; this table is your system of record for DDNS operations.

```sql
CREATE TABLE Records (
    RecordId        BIGINT IDENTITY(1,1) PRIMARY KEY,
    ZoneId          BIGINT        NOT NULL,
    Name            NVARCHAR(255) NOT NULL, -- relative to zone, e.g., 'router', '@'
    Type            VARCHAR(16)   NOT NULL, -- A, AAAA, CNAME, TXT, etc.
    Ttl             INT           NOT NULL,
    -- store data as text; normalize further if needed
    Value           NVARCHAR(512) NOT NULL,
    IsLocked        BIT           NOT NULL DEFAULT 0, -- prevent DDNS changes
    CreatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    IsDeleted       BIT           NOT NULL DEFAULT 0,
    CONSTRAINT FK_Records_Zones FOREIGN KEY (ZoneId) REFERENCES Zones (ZoneId),
    -- Efficient lookups and uniqueness per zone/name/type/value combination
    CONSTRAINT IX_Records_ZoneNameType UNIQUE (ZoneId, Name, Type, Value)
);
```
You might maintain only the “desired state” here and periodically reconcile with Azure DNS.

## 4. Credentials and update methods
### 4.1 Table: Credentials
One generic table for all credential types (RFC2136, API keys, Azure-auth client allowances).

```sql
CREATE TABLE Credentials (
    CredentialId       BIGINT IDENTITY(1,1) PRIMARY KEY,
    TenantId           BIGINT        NOT NULL,
    CredentialType     VARCHAR(32)   NOT NULL,
    -- e.g., 'RFC2136_KEY', 'API_KEY', 'AAD_APP_ID'
    DisplayName        NVARCHAR(256) NOT NULL,
    -- For secrets stored in Key Vault, this is a reference/URI, not the secret itself
    SecretRef          NVARCHAR(512) NULL,
    -- For Azure-auth clients, store clientId / objectId if needed
    ExternalPrincipalId NVARCHAR(128) NULL, -- e.g., AAD appId
    Status             VARCHAR(32)   NOT NULL DEFAULT 'Active', -- Active, Revoked
    CreatedAtUtc       DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc       DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    LastUsedAtUtc      DATETIME2(3)  NULL,
    CONSTRAINT FK_Credentials_Tenants FOREIGN KEY (TenantId) REFERENCES Tenants (TenantId)
);
```
### 4.2 Table: CredentialZones
Which zones a given credential can update.

```sql
CREATE TABLE CredentialZones (
    CredentialZoneId BIGINT IDENTITY(1,1) PRIMARY KEY,
    CredentialId     BIGINT NOT NULL,
    ZoneId           BIGINT NOT NULL,
    -- Optional: further restrictions (record types, hostnames)
    AllowedRecordTypes NVARCHAR(128) NULL, -- e.g., 'A,AAAA'
    AllowedNames     NVARCHAR(512) NULL,   -- e.g., 'router,*,vpn'
    CONSTRAINT FK_CredentialZones_Credentials FOREIGN KEY (CredentialId) REFERENCES Credentials (CredentialId),
    CONSTRAINT FK_CredentialZones_Zones FOREIGN KEY (ZoneId) REFERENCES Zones (ZoneId),
    CONSTRAINT UQ_CredentialZones UNIQUE (CredentialId, ZoneId)
);
```
You can extend with more granular rules later.

## 5. Activity, logs, and quotas
### 5.1 Table: DdnsUpdates
Log of all DDNS update attempts (for audit and troubleshooting).

```sql
CREATE TABLE DdnsUpdates (
    DdnsUpdateId    BIGINT IDENTITY(1,1) PRIMARY KEY,
    TenantId        BIGINT        NOT NULL,
    ZoneId          BIGINT        NOT NULL,
    CredentialId    BIGINT        NULL, -- may be null for some auth paths
    SourceType      VARCHAR(32)   NOT NULL, -- 'RFC2136', 'HTTPS_API_KEY', 'HTTPS_AAD'
    SourceIp        VARCHAR(64)   NULL,
    RecordName      NVARCHAR(255) NOT NULL,
    RecordType      VARCHAR(16)   NOT NULL,
    Operation       VARCHAR(16)   NOT NULL, -- 'ADD', 'UPDATE', 'DELETE'
    RequestedValue  NVARCHAR(512) NULL,
    PreviousValue   NVARCHAR(512) NULL,
    Result          VARCHAR(16)   NOT NULL, -- 'SUCCESS', 'FAILED'
    ErrorCode       NVARCHAR(64)  NULL,
    ErrorMessage    NVARCHAR(512) NULL,
    CorrelationId   NVARCHAR(64)  NULL,
    TimestampUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_DdnsUpdates_Tenants FOREIGN KEY (TenantId) REFERENCES Tenants (TenantId),
    CONSTRAINT FK_DdnsUpdates_Zones FOREIGN KEY (ZoneId) REFERENCES Zones (ZoneId),
    CONSTRAINT FK_DdnsUpdates_Credentials FOREIGN KEY (CredentialId) REFERENCES Credentials (CredentialId)
);
```
Indexes to consider:
- IX_DdnsUpdates_Tenant_Time (TenantId, TimestampUtc DESC)
- IX_DdnsUpdates_Zone_Time (ZoneId, TimestampUtc DESC)
- IX_DdnsUpdates_Credential_Time (CredentialId, TimestampUtc DESC)

### 5.2 Table: UsageDaily
Aggregated per-tenant usage metrics to enforce quotas and for reporting.

```sql
CREATE TABLE UsageDaily (
    UsageDate       DATE          NOT NULL,
    TenantId        BIGINT        NOT NULL,
    ZoneCount       INT           NOT NULL, -- snapshot of zone count that day
    RecordCount     INT           NOT NULL, -- snapshot of record count that day
    RequestsCount   INT           NOT NULL, -- total DDNS requests that day
    PRIMARY KEY (UsageDate, TenantId),
    CONSTRAINT FK_UsageDaily_Tenants FOREIGN KEY (TenantId) REFERENCES Tenants (TenantId)
);
```
You can update RequestsCount in near real-time from your gateway, or batch from DdnsUpdates with a job.

## 6. Portal and user-related data
### 6.1 Table: TenantUsers
Who has accessed/has access to the portal for this tenant, if you maintain roles in your own DB.

```sql
CREATE TABLE TenantUsers (
    TenantUserId    BIGINT IDENTITY(1,1) PRIMARY KEY,
    TenantId        BIGINT        NOT NULL,
    UserObjectId    NVARCHAR(64)  NOT NULL, -- from Entra ID
    UserPrincipalName NVARCHAR(256) NULL,
    DisplayName     NVARCHAR(256) NULL,
    Role            VARCHAR(32)   NOT NULL, -- 'Admin', 'Operator', 'Viewer'
    CreatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc    DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_TenantUsers_Tenants FOREIGN KEY (TenantId) REFERENCES Tenants (TenantId),
    CONSTRAINT UQ_TenantUsers UNIQUE (TenantId, UserObjectId)
);
```
### 6.2 Table: TenantSettings
Misc tenant-level configuration and preferences.

```sql
CREATE TABLE TenantSettings (
    TenantId        BIGINT       NOT NULL PRIMARY KEY,
    TimeZoneId      NVARCHAR(64) NULL,
    NotificationEmail NVARCHAR(256) NULL,
    NotifyOnQuota80 BIT          NOT NULL DEFAULT 1,
    NotifyOnQuota100 BIT         NOT NULL DEFAULT 1,
    CreatedAtUtc    DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc    DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_TenantSettings_Tenants FOREIGN KEY (TenantId) REFERENCES Tenants (TenantId)
);
```
## 7. Data integrity, constraints, and patterns
### 7.1 Referential integrity and cascading rules
- Foreign keys are used everywhere to keep relationships valid.
- For safety, prefer soft deletes (e.g., IsDeleted) over cascade deletes:
  - When a tenant is cancelled, set Status = 'Cancelled', don’t delete.
  - When a zone is “deleted”, set IsDeleted = 1 and optionally remove from Azure DNS separately.

### 7.2 Quota enforcement
You’ll typically enforce quotas in the application layer, but you can make it easy:

- Count zones per tenant using:
```sql
sql
SELECT COUNT(*)
FROM Zones
WHERE TenantId = @TenantId AND IsDeleted = 0;
```
- Count records per zone similarly.
- Requests per day: read from UsageDaily and / or DdnsUpdates.

You could add computed or indexed views to speed up usage queries if needed.

### 7.3 Secrets handling
For TSIG/API keys, only store SecretRef (e.g., Key Vault secret URI or custom ID).

The application retrieves the actual secret from Key Vault; Azure SQL never contains raw secrets.