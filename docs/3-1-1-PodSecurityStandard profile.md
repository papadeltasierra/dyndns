# PodSecurityStandard profile

Below is a pure Markdown, production‑ready Pod Security Standard (PSS) profile for your AKS namespace.
PodSecurityPolicy (PSP) is deprecated and removed in Kubernetes 1.25+, and AKS follows this, so the correct modern approach is Pod Security Standards enforced via Namespace labels and optional AdmissionConfiguration.

> !!PDS: Need to merge this in.

I'll give you:
- A PSS namespace configuration (recommended for AKS)
- A PSS‑aligned NetworkPolicy‑friendly securityContext template
- A PSP‑style YAML (for legacy clusters only)

Everything is clean, minimal, and ready to paste into your repo.

## 1. Pod Security Standard (PSS) — Namespace Labels
(Recommended for AKS)

Apply this to your ddns namespace to enforce `baseline` or `restricted` security.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ddns
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```
What this does
- Enforces restricted PSS (the strongest profile)
- Blocks privileged containers
- Blocks hostPath, hostNetwork, hostPID, hostIPC
- Requires non‑root
- Requires read‑only root filesystem (unless overridden)
- Requires dropping all capabilities

This is the correct zero‑trust posture for your DDNS platform.

## PSS‑Compliant Pod Template (for your Deployments)
Use this in your API, RFC2136 gateway, and other workloads.

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  seccompProfile:
    type: RuntimeDefault
  capabilities:
    drop:
      - ALL
```
Container‑level example

```yaml
containers:
  - name: ddns-api
    image: youracr.azurecr.io/ddns-api:latest
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        drop:
          - ALL
```
This satisfies restricted PSS.

## (Optional) Legacy PodSecurityPolicy (PSP)
Only for clusters <1.25

AKS no longer supports PSP, but if you need it for reference or older clusters, here is a compliant PSP.

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ddns-restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  fsGroup:
    rule: MustRunAs
    ranges:
      - min: 1
        max: 65535
  supplementalGroups:
    rule: MustRunAs
    ranges:
      - min: 1
        max: 65535
  volumes:
    - configMap
    - secret
    - projected
    - emptyDir
  readOnlyRootFilesystem: true
```
## Recommended Setup for Your DDNS Platform
|Component|	PSS Level|	Notes|
|-|-|-|
|API|	restricted|	No privileged operations needed|
|RFC2136 Gateway|	restricted|	DNS over UDP/TCP 53 is fine|
|Portal|	restricted|	Standard web app|
|Monitoring agents|	baseline|	Some agents need extra permissions|
|Namespace default|	restricted|	Strongest posture|
