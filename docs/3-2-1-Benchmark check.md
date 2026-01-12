Absolutely — a solid CIS Benchmark checklist gives you a clear, opinionated baseline for hardening your AKS cluster. What I’ve put together below is a concise but comprehensive checklist aligned with the CIS Kubernetes Benchmark v1.8 and tailored specifically for AKS, where Microsoft manages the control plane and you secure the node plane, workloads, and configuration.

This is written in pure Markdown, so you can drop it straight into your repo under docs/security/aks-cis-checklist.md.

CIS Benchmark Checklist for AKS
A practical, AKS‑specific hardening guide

## 1. Cluster & Control Plane (AKS‑Managed)
Even though AKS manages the control plane, you still validate configuration.

✔ Ensure:
- API server is private (Private AKS) or restricted by IP ranges
- RBAC is enabled
- Azure AD integration is enabled
- Audit logs are enabled (via Azure Monitor / Log Analytics)
- Kubernetes version is supported and current
- API server authorized IP ranges are configured (if not private)
- Admin account is disabled or tightly controlled
- Local accounts are disabled (--disable-local-accounts)

## 2. Node Security (Your Responsibility)
✔ Ensure:
- Nodes use Azure-managed OS images (not custom unmanaged images)
- Nodes are not publicly exposed
- SSH access is disabled unless explicitly required
- VMSS uses automatic OS patching
- Disk encryption is enabled (default for AKS)
- Nodes run in a dedicated subnet
- Network policies are enabled (Azure CNI + Calico or Cilium)
- Pod CIDR and Service CIDR are non-overlapping and private

## 3. Authentication & Authorization
✔ Ensure:
- Azure AD RBAC is enforced
- Kubernetes RBAC roles follow least privilege
- No use of cluster-admin except break-glass
- No service accounts with automountServiceAccountToken: true unless required
- Service accounts use Workload Identity (recommended)
- Managed Identities replace secrets wherever possible

## 4. Pod Security Standards (PSS)
✔ Namespace labels:
```bash
pod-security.kubernetes.io/enforce: restricted
pod-security.kubernetes.io/enforce-version: latest
```
✔ Workloads must:
- Run as non-root
- Drop ALL Linux capabilities
- Use seccomp: RuntimeDefault
- Use AppArmor where supported
- Use read-only root filesystem
- Avoid hostPath, hostNetwork, hostPID, hostIPC
- Avoid privileged containers

## 5. Network Security
✔ Ensure:
- NetworkPolicy is enabled
- Default deny ingress and egress policies exist
- API ingress restricted to APIM
- API egress restricted to SQL + Key Vault
- RFC2136 Gateway ingress restricted to labeled pods
- No pod-to-pod traffic allowed unless explicitly permitted
- AKS cluster uses Azure CNI with private IPs
- AKS subnet is isolated from other VNets unless required

## 6. Secrets & Key Management
✔ Ensure:
- No Kubernetes Secrets stored in plain text
- Use Azure Key Vault CSI driver for secrets
- Use Managed Identity for Key Vault access
- Disable secret environment variables where possible
- Rotate secrets regularly
- Ensure Key Vault firewall restricts access to Private Endpoint only

## 7. Logging & Monitoring
✔ Ensure:
- Azure Monitor / Log Analytics enabled
- Container insights enabled
- Audit logs collected (API server, control plane)
- Diagnostic settings enabled for:
  - AKS cluster
  - Node resource group
  - Key Vault
  - SQL
- Alerts configured for:
  - Unauthorized access
  - Pod creation failures
  - Node pool scaling failures
  - High API error rates

## 8. Image Security
✔ Ensure:
- Only pull images from ACR
- ACR firewall enabled + Private Endpoint
- Image scanning enabled (Microsoft Defender for Cloud)
- No latest tags in production
- Use signed images (Notary v2 / OCI artifacts)
- Avoid root images
- Multi-stage builds to minimize attack surface

## 9. Workload Security
✔ Ensure:
- Liveness/readiness probes configured
- Resource limits set (CPU/memory)
- HPA enabled for critical workloads
- PDBs configured
- No privileged pods
- No hostPath volumes
- No host networking
- No wildcard RBAC rules
- No containers running as root

## 10. Network & Private Endpoints
✔ Ensure:
- SQL uses Private Endpoint
- Key Vault uses Private Endpoint
- ACR uses Private Endpoint
- APIM uses VNet integration or IP restrictions
- No public endpoints unless explicitly required
- DNS resolution uses Azure Private DNS Zones

## 11. Supply Chain Security
✔ Ensure:
- GitHub Actions uses OIDC federated identity (no secrets)
- Code scanning enabled (GitHub Advanced Security or Defender)
- Dependency scanning enabled
- SBOM generated (CycloneDX)
- CI/CD enforces branch protection + approvals
- No direct pushes to main

## 12. Backup & Recovery
✔ Ensure:
- SQL backups configured
- Key Vault soft-delete + purge protection enabled
- ACR retention policies configured
- AKS cluster configuration stored in Git (GitOps)
- Disaster recovery plan documented