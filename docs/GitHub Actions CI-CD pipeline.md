# GitHub Actions CI/CD pipeline
A clean, production‑ready GitHub Actions CI/CD pipeline, written entirely in pure Markdown, with no extra commentary or system‑level artifacts. It’s designed specifically for your .NET API + Portal and Bicep IaC deployment model.

It includes:
- Build + test for API and Portal
- Publish artifacts
- Deploy API + Portal to Azure App Service
- Deploy infrastructure using Bicep
- Optional AKS deployment stage (commented)
- Environment‑based separation (dev/stage/prod)

You can drop this straight into .github/workflows/ci-cd.yml.