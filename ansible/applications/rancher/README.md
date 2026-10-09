# `rancher` role

1. Issues the Rancher ingress certificate from a private CA, once per cluster, into the
   `tls-rancher-ingress` and `tls-ca` secrets.
2. Hands RKE2's helm-controller a `HelmChart` for a pinned Rancher Manager release.
3. Proves Rancher: every replica rolls out, and `/ping` answers `pong` through the load balancer,
   by name, against the private CA.

## Composition and prerequisites

Overlaid into the pinned ansible-framework's `applications/` namespace and run by
`ansible/playbooks/rancher-aws.yml` on the RKE2 server that initialized the cluster, after the
`rke2` role has made every node Ready. It uses that server's own `kubectl` and kubeconfig; no Helm
client is installed anywhere. The servers carry `CriticalAddonsOnly`, so Rancher's replicas and the
Traefik ingress run on the agents, which is where the load balancer sends 80 and 443.

## Inputs

| Key | Required | Meaning |
|---|---|---|
| `version` | yes | Rancher Manager release, e.g. `2.15.2` (its chart admits Kubernetes below 1.37) |
| `hostname` | yes | the name Rancher is reached by: the load balancer's DNS name |
| `bootstrap_password` | yes | the first administrator's password, at least 12 characters |

Everything else is in `defaults/main.yml`, each value with its reason.

## STIG settings (RGS Rancher Multi-Cluster Manager STIG V2R2)

| Rule | Setting |
|---|---|
| V-252844 | API audit log enabled at level 2 (request bodies), to the chart's sidecar |
| V-257292 | `privateCA: true`, `ingress.tls.source: secret`: the certificate comes from a private CA, not Rancher's self-signed issuer. A DoD-issued certificate replaces the bed's CA where one exists |
| (TLS) | `agentTLSMode: strict` |

Not yet configured, each a later chunk: V-252843 (an external authentication provider),
V-252845 (new-user default role), V-252846 (Rancher Logging), V-252849 (ingress backend on 443 and
the `cattle-system` NetworkPolicies). V-252847 (one local administrator) holds by default.

## State

`present` only. Rancher is removed with the cluster.

## Verification

The role ends by waiting for the `rancher` deployment's rollout and for `https://<hostname>/ping`
to answer `pong`, verified against the private CA. A second converge reports `changed=0`.
