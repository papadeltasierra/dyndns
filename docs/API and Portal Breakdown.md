# API Project by Copilot
> !!PDS: This appears to be incomplete.  Can we recover it?

1. API Project (Ddns.Api)
- A minimal, modern ASP.NET Core Web API using:
- Minimal APIs or Controllers (your choice)
- Dependency Injection
- Managed Identity support
- Azure SQL access via EF Core or Dapper
- Azure DNS SDK integration
- Azure Key Vault integration
- Authentication via Azure AD (JWT)
- Logging via Application Insights

```bash
/src
  /Ddns.Api
    /Controllers
    /Services
    /Domain
    /Infrastructure
    /Models
    /Dtos
    /Auth
    /Config
    appsettings.json
    Program.cs
    Ddns.Api.csproj

  /Ddns.Portal
    /Pages
    /Components
    /Services
    /Models
    /Auth
    appsettings.json
    Program.cs
    Ddns.Portal.csproj

/tests
  /Ddns.Api.Tests
  /Ddns.Portal.Tests

/build
  Directory.Build.props
  Directory.Build.targets

.sln
```