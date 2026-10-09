# `rke2` role

1. Prepares a CIS RHEL 9 STIG host for RKE2: kernel parameters, the etcd account, NetworkManager,
   the host firewall, and fapolicyd.
2. Installs a pinned RKE2 release from Rancher's signed RPM repositories.
3. Configures the node to the Rancher Government Solutions RKE2 STIG (V2R7) and starts it as a
   server or an agent.
4. Proves the node: the kubelet answers healthy, and a server reports Ready.

## Composition and prerequisites

Overlaid into the pinned ansible-framework's `applications/` namespace and run by
`ansible/playbooks/rancher-aws.yml` after `credential_resolver`, `host_readiness`, `os_bootstrap`
and `linux_disk_manager` (which mounts the node's data volume at `/var/lib/rancher`). The shared
v3 loader in `tasks/main.yml` is framework-owned and never edited.

## Inputs

| Key | Required | Meaning |
|---|---|---|
| `version` | yes | RKE2 release, e.g. `v1.36.5+rke2r1`; the RPM version is derived from it |
| `node_role` | yes | `server` or `agent` |
| `token` | yes | the cluster join secret, at least 32 characters |
| `server_url` | agents, joining servers | `https://<load balancer>:9345`; empty on the initializing server |
| `tls_san` | servers | extra certificate names (the load balancer) |

Everything else is in `defaults/main.yml`, each value with its reason.

## STIG settings

| Rule | Setting |
|---|---|
| CNTR-R2-000010 | control plane `tls-min-version=VersionTLS12` and the three STIG ECDSA cipher suites |
| CNTR-R2-000030 | controller manager `use-service-account-credentials=true` |
| CNTR-R2-000060 | `profile: cis`; the audit policy (secrets at Metadata, everything else RequestResponse) exists before the first start; `audit-log-mode=blocking-strict` |
| CNTR-R2-000100 | controller manager `bind-address=127.0.0.1` |
| CNTR-R2-000110 / 000130 / 000150 / 000890 / 000940 | kubelet `anonymous-auth=false`, `read-only-port=0`, `authorization-mode=Webhook`, `streaming-connection-idle-timeout=5m`, `protect-kernel-defaults=true` |
| CNTR-R2-000160 / 000320 / 001270 | API server `anonymous-auth=false`, `audit-log-maxage=30`, `authorization-mode=RBAC,Node` |
| CNTR-R2-000520 | `/etc/rancher/rke2/*` 0600 root; `write-kubeconfig-mode: 0600`; once RKE2 is up, its binaries and `data/`, `server/manifests`, `server/logs` restricted to 0750 and `agent/etc`, `agent/pod-manifests` to 0700 (RKE2 creates them 0755) |
| CNTR-R2-001130 | Pod Security Admission restricted by default; exemptions are Rancher's published list |
| CNTR-R2-000550 | the unused volume-snapshot components are disabled |

## Placement

The servers carry `CriticalAddonsOnly=true:NoExecute`. The API server also enables
`PodNodeSelector` and `PodTolerationRestriction` beside NodeRestriction, and RKE2's own Deployments
(CoreDNS, metrics-server) and Traefik are pinned to the management pool through a `HelmChartConfig`
the role writes on each server. The `cluster_placement` role labels the pools and enforces the split.

## CIS RHEL 9 STIG image constraints (measured 2026-10-09)

| Image fact | Consequence here |
|---|---|
| nftables loads `inet filter` with input, forward and output policy drop; firewalld also runs | both are stopped and disabled, and the table is removed before RKE2 starts. RKE2 and Rancher require it; the security groups are the network boundary. Documented STIG exception: RHEL-09-251010 |
| fapolicyd installed but disabled | enabled and started (RHEL-09-433010/015), with rules allowing execution under RKE2's data, CNI and kubelet trees |
| `ip_forward = 0`, kernel defaults unlike the CIS profile's | `/etc/sysctl.d/99-zz-rke2.conf` sorts last. Forwarding is a documented RHEL-09-253075 exception: a node routes pod traffic |
| `/var` is 10 GiB | RKE2's data lives on the node's own volume at `/var/lib/rancher` |
| `nm-cloud-setup` enabled | stopped and disabled, as RKE2 requires |
| kernel FIPS mode on, SELinux enforcing, cgroup v2 | RKE2's FIPS build and `selinux: true`; `rke2-selinux` arrives with the RPM |

## State

`present` only. Removal is a node rebuild: the deploy is ephemeral, and a held bed is rebuilt
from Terraform rather than uninstalled.

## Verification

The role ends by waiting for the kubelet's `/healthz`, and on a server for its node to report
Ready. A second converge reports `changed=0`.
