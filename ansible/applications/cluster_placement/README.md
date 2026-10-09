# `cluster_placement` role

The management/worker split. **What this repository deploys runs on the management nodes (the RKE2
servers); applications deployed from elsewhere run on the workers (the agents).**

1. Labels every node with its pool: `nwarila.io/pool=management` or `nwarila.io/pool=workers`.
2. Creates this repository's namespaces (Rancher's and Fleet's) labelled `nwarila.io/platform=true`
   and annotated for the API server's `PodNodeSelector` and `PodTolerationRestriction` plugins,
   which the `rke2` role enables: every pod in them gets the management pool's node selector and
   the toleration the servers' `CriticalAddonsOnly` taint requires. It runs before Rancher, so
   Rancher's pods land on the management nodes from the first.
3. Applies the `applications-run-on-workers` ValidatingAdmissionPolicy: outside the platform
   namespaces (and `kube-system`, also labelled platform), a pod may not tolerate the management
   taint, by key or with a keyless `Exists`. Without that toleration nothing schedules onto the
   servers, so an application can never land there, whatever it asks for.
4. Restarts the Deployments of any platform namespace that still has a pod on a worker (a cluster
   built before this role ran), then proves nothing of ours remains on a worker: no pod in a
   platform namespace, and no RKE2 add-on Deployment in `kube-system`.

## Composition

Runs once per converge on the RKE2 server that initialized the cluster, after both RKE2 plays and
before the Rancher play. The `rke2` role pins RKE2's own Deployments and Traefik to the management
pool through `HelmChartConfig`, because `kube-system` carries no placement annotation: the CNI's
DaemonSet must run on every node. The load balancer's 80/443 target groups therefore point at the
servers.

## Inputs

| Key | Meaning |
|---|---|
| `management_nodes` | node names of the servers (the playbook passes `groups['rancher_servers']`) |
| `worker_nodes` | node names of the agents (`groups['rancher_agents']`) |

A namespace the stack adds later (Vault's, for instance) joins `platform_namespaces` in
`defaults/main.yml`.

## Why not a cluster-wide default node selector

`PodNodeSelector`'s `clusterDefaultNodeSelector` would place every unannotated namespace on the
workers, including `kube-system` at the very first API server start, before anything could exempt
it: the CNI's pods on the servers would never schedule. The admission policy closes the same gap
as an ordinary object created after bootstrap.

## Verification (measured 2026-10-09)

A plain pod in a new namespace ran on a worker; pods tolerating the management taint by key, or
every taint, were denied by the policy; Rancher's three replicas ran one per server. A second
converge reports `changed=0`.
