# ============================
# 1. Build stage
# ============================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and restore
COPY *.sln .
COPY Ddns.Portal/*.csproj Ddns.Portal/
COPY Ddns.Shared/*.csproj Ddns.Shared/
RUN dotnet restore

# Copy everything and build
COPY . .
RUN dotnet publish Ddns.Portal/Ddns.Portal.csproj -c Release -o /app/publish

# ============================
# 2. Runtime stage
# ============================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy published output
COPY --from=build /app/publish .

# Use non-root user for security
USER $APP_UID

# Expose port
EXPOSE 8080

# Run Portal
ENTRYPOINT ["dotnet", "Ddns.Portal.dll"]
