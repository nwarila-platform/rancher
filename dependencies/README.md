# Dependency declarations

This tree is this repository's declared dependency contract for the organization estates.
`dependencies/aws/` is desired state. It was exported from live IAM on 2026-10-09, changed where the
"Changes from the live export" section below says, and applied the same day with
`scripts/apply-dependencies.sh`, so live IAM and the estate equal this tree. The owner reviews this
tree before any AWS apply.

The layout is the one `nwarila-platform/secure-wazuh` introduced, `nwarila-platform/nessus`
extended, and `nwarila-platform/keycloak` gave its standing estate; see "Copy this pattern".

## Layout

`aws/policies/` contains one desired customer-managed IAM document per object. Policy metadata
lives in `aws/manifest.json`. There is no `aws/proposed/` tree: desired changes are made in the
real policy files and recorded in the manifest's `divergence` block until they are applied.

`aws/roles/` pairs each desired trust document with a role sidecar: session duration, customer and
AWS-managed attachments, the trust filename, path, nullable description and ownership.

`aws/manifest.json` keeps the export date, each attached policy's live version at that export, and
the authoritative role-to-policy attachments for the closed set: three roles, zero profiles, and
seventeen customer-managed policies.

`aws/artifacts.yml` declares the consumed S3 objects. The RKE2 stack consumes none: its RPMs come
from `rpm.rancher.io` over the nodes' own HTTPS egress, and the cluster join token is generated on
the controller.

`aws/estate.yml` declares the standing, zero-cost objects the pinned aws-terraform-framework
consumes but never creates:
- the Elastic Load Balancing service-linked role, which a first load balancer create needs;
- two security groups. `rancher-node` is a rule-less membership group every node carries, and
  `rancher-nlb`, the network load balancer's group, admits only that group on 80, 443, 6443 and
  9345. Reachability is by membership, not by address. The nodes' own rules -- node to node, and
  from the load balancer -- are run-scoped and live in `terraform/aws.tfvars`.

There is no `ad/` directory: the Rancher nodes join no directory.

## Changes from the live export

Every document not listed here equals the 2026-10-09 export, which is the fleet skeleton baseline.

**`nwarila-platform_rancher_runner_elb`** (new) creates and deletes one network load balancer,
`rancher`, with its listeners and its provider-named (`tf-`) target groups. It is keycloak's
application load balancer policy moved to `loadbalancer/net/` and `listener/net/` ARNs, plus
`elasticloadbalancing:SetSecurityGroups` on the owned load balancer: the framework forces
`enforce_security_group_inbound_rules_on_private_link_traffic = "on"` on a network load balancer,
and the provider applies it with one `SetSecurityGroups` call after the create (CloudTrail,
2026-10-09).
- Creation requires the deploy identity tags, and the load balancer must be internal.
- Listeners may be created only on the `rancher` load balancer.
- Tags may be written only during creation.
- Modify, register, deregister, set-security-groups and delete require the identity tags.
- Describe actions support no resource scoping and are granted on `*`.

**`nwarila-platform_rancher_runner_ec2`** launches only `t3.large` instances. The baseline's
tagged-creation statement is split in two, as in keycloak: `ec2:InstanceType` exists on the
instance resource and not on the volume, so one statement carrying it would deny every volume.

**`nwarila-platform_rancher_reaper_elb`** (new) is the destroy-only half: describe, plus tag-scoped
delete and deregister.

**`nwarila-platform_rancher_admin`** converges a held bed by hand and never builds the stack, so it
carries the baseline runner policies and `admin_s3`, but not `runner_elb`: nine policies, unchanged
from live.

## Applying

`scripts/apply-dependencies.sh` is the only apply path. Run it with an administrator profile:

~~~bash
scripts/apply-dependencies.sh [--apply] [aws-profile]
~~~

Without `--apply` it plans and writes nothing; it exits 0 in sync, 2 with changes pending, and 1 on
any failure, naming the command that failed. It renders every document from live values, refuses
any unrendered token, validates every document with IAM Access Analyzer, and reports every
difference between this tree and live IAM and estate. It refuses to adopt a same-named security
group that does not carry this tree's estate tags. With `--apply` it writes those differences,
re-plans and requires no difference, simulates each role against requests its guards must allow and
deny, and prints the security group ids `terraform/aws.tfvars` consumes.

## External dependencies

The hosts launch with the shared instance profile `nwarila-ec2-profile`, which carries SSM alone.
That profile is registry-owned; `terraform/aws.tfvars` selects it, and the runner holds
`iam:PassRole` and `iam:GetInstanceProfile` on it. The Elastic Load Balancing service-linked role is
account-wide: whichever repository's apply runs first creates it.

## Registry shim

`registry-values.yml` is the sacrificial local resolver. It is empty, because no declaration here
references a registry URI yet. Delete that one file when the organization registry exists.

## Integrity

Every file below `dependencies/`, except `MANIFEST.sha256`, is covered by the manifest. Regenerate
it from the repository root with exactly:

~~~bash
(cd dependencies && LC_ALL=C find . -type f ! -name MANIFEST.sha256 -print0 | LC_ALL=C sort -z \
  | xargs -0 sha256sum > MANIFEST.sha256)
~~~

Verify it with `(cd dependencies && sha256sum -c MANIFEST.sha256)`. The credential-free validator,
`scripts/check-dependencies.py`, also checks schemas, metadata, attachments, closure, tokens,
literals, canonical JSON, negations, divergence references, the estate, the IAM quota, and that the
playbook reads no S3 object this tree does not declare.

## Known gaps

- **Not yet proven by the runner.** The new load balancer grants were derived from a CloudTrail
  record of the provider's calls under an administrator, not from a run as the runner role. The
  apply's simulations evidence the guards; the first workflow deploy evidences completeness.
- **Baseline grants this repository does not use.** `runner_s3` grants `s3:GetObject` on the
  domain-join secret, the VPN profile and all of `<account-id>-apprepo/*`; `runner_ssm` grants
  `SendCommand` with the PowerShell document; `runner_iam` reads and passes the apprepo profile.
  These remain in the fleet baseline pending a separately reviewed, fleet-wide hardening change.

## Copy this pattern

Declare only the objects you own; keep policy metadata and attachments in one manifest; declare
owned standing estate in `estate.yml` with reachability by membership; close every URI, attachment,
token, literal, checksum and divergence reference in the validator.
