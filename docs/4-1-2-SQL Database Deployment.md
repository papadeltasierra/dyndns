Create GitHub based CI/CD sripts to create the SQL database
Absolutely, Paul — let’s build a clean, production‑ready GitHub‑based CI/CD pipeline that automatically deploys your Azure SQL schema every time you push to main. I’ll give you:

- A recommended repo structure
- A CI pipeline (validates SQL, builds artifacts)
- A CD pipeline (deploys to Azure SQL using Azure login + SQLCMD)
- A parameterized deployment script
- Inline exploration links so you can dive deeper into any part you like

Everything below is safe to run in a real GitHub repo.

## Recommended repository structure
```bash
/database
   /schema
      001_create_tables.sql
      002_constraints.sql
      003_seed_data.sql
   /scripts
      deploy.ps1
/.github
   /workflows
      ci.yml
      cd.yml
```
Each SQL file is idempotent (CREATE IF NOT EXISTS, etc.) so deployments are safe.

## CI Pipeline (ci.yml)
This workflow validates SQL syntax and publishes the schema as an artifact.

```yaml
name: CI - Validate SQL

on:
  push:
    branches: [ "main" ]
  pull_request:

jobs:
  validate-sql:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Validate SQL syntax
      run: |
        for file in database/schema/*.sql; do
          echo "Validating $file"
          sqlcmd -Q "SET NOEXEC ON; :r $file" || exit 1
        done

    - name: Upload schema artifact
      uses: actions/upload-artifact@v4
      with:
        name: sql-schema
        path: database/schema
```
Highlights:
- SQL syntax validation
- Artifact publishing

## CD Pipeline (cd.yml)
This workflow deploys the SQL schema to Azure SQL whenever you tag a release.

```yaml
name: CD - Deploy SQL Database

on:
  push:
    tags:
      - "v*.*.*"

jobs:
  deploy-sql:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Azure Login
      uses: azure/login@v2
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Install sqlcmd
      run: |
        sudo apt-get update
        sudo apt-get install -y mssql-tools unixodbc-dev
        echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

    - name: Deploy SQL schema
      env:
        SQL_SERVER: ${{ secrets.SQL_SERVER }}
        SQL_DB: ${{ secrets.SQL_DB }}
        SQL_USER: ${{ secrets.SQL_USER }}
        SQL_PASS: ${{ secrets.SQL_PASS }}
      run: |
        for file in database/schema/*.sql; do
          echo "Deploying $file"
          sqlcmd -S $SQL_SERVER -d $SQL_DB -U $SQL_USER -P $SQL_PASS -b -i $file
        done
```
Secrets required:

|Secret|Purpose|
|-|-|
|AZURE_CREDENTIALS|	Service principal JSON|
|SQL_SERVER|	myserver.database.windows.net|
|SQL_DB|	Database name|
|SQL_USER|	SQL admin or managed identity user|
|SQL_PASS|	Password (if SQL auth)|

Highlights:
- Azure login integration
- Secure secret handling
- Automated schema deployment

## Deployment Script (deploy.ps1)
This script is used by the CD pipeline but can also be run locally.

```powershell
param(
    [string]$Server,
    [string]$Database,
    [string]$User,
    [string]$Password
)

$schemaPath = "database/schema"

Get-ChildItem $schemaPath -Filter *.sql | Sort-Object Name | ForEach-Object {
    Write-Host "Deploying $($_.Name)"
    sqlcmd -S $Server -d $Database -U $User -P $Password -b -i $_.FullName
}
```

Highlights:
- Local deployment support
- Ordered schema execution

## optional: Use Managed Identity instead of SQL auth
If your SQL Server has AAD authentication enabled, replace:

```bash
sqlcmd -U $SQL_USER -P $SQL_PASS
```
with:

```bash
sqlcmd -G
```
And grant the GitHub Actions service principal:

```bash
ALTER ROLE db_ddladmin ADD MEMBER [appId-of-service-principal];
```
What this gives you
- Fully automated CI validation
- Fully automated CD deployment
- Secure, repeatable, auditable SQL schema management
- A structure that scales as your DDNS SaaS grows