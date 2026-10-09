# `rancher` role

1. Issues the Rancher ingress certificate from a private CA, once per cluster, into the
   `tls-rancher-ingress` and `tls-ca` secrets.
2. Hands RKE2's helm-controller a `HelmChart` for a pinned Rancher Manager release, and RKE2 the
   Traefik transport and NetworkPolicies that keep the hop into Rancher TLS-only.
3. Sets the new-user default global role.
4. Proves Rancher: the ingress backend is 443, both policies exist, every replica rolls out, and
   `/ping` answers `pong` through the load balancer, by name, against the private CA.

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
| V-252845 | global role `user-base` is the new-user default, `user` (Standard User) is not; set once Rancher has created them, and held across a Rancher restart |
| V-252847 | one local account, `admin`; holds by default (Rancher's system accounts carry no username) |
| V-252849 | the ingress reaches Rancher on 443 (`ingress.servicePort: 443`, `router.tls`); `rancher-allow-https` and `rancher-deny-ingress` admit only TLS into the Rancher pods |
| (TLS) | `agentTLSMode: strict` |

Not yet configured, each a later chunk: V-252843 (an external authentication provider) and
V-252846 (Rancher Logging).

### Documented deviations (V-252849)

- **Ports.** The STIG's `rancher-allow-https` admits 444 alone. Rancher 2.15's chart routes the
  ingress to the pods' 443 (Service `rancher` 443->443) and registers the `ext.cattle.io` APIService
  on 6666, so the policy admits 443, 444 and 6666 -- all TLS. Port 80, the one plain-HTTP listener,
  is denied (measured 2026-10-09: 80 times out from another node; 443 and 444 answer).
- **Backend verification.** Traefik speaks TLS to Rancher but does not verify its certificate,
  through a `ServersTransport` scoped to Rancher's Service alone: that certificate comes from
  Rancher's rotating internal CA, which Traefik reads only from a `ca.crt` key Rancher does not
  write. The STIG's own NGINX fix (`backend-protocol: HTTPS`) does not verify either.

## State

`present` only. Rancher is removed with the cluster.

## Verification

The role ends by waiting for the `rancher` deployment's rollout and for `https://<hostname>/ping`
to answer `pong`, verified against the private CA. A second converge reports `changed=0`.
