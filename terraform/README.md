# terraform/ — data only

This directory carries **no `.tf` files and never will**. The AWS resources are declared by the
pinned `nwarila-platform/aws-terraform-framework`; this repository contributes only the variable
input that shapes them.

- `aws.tfvars` — the system declaration consumed verbatim by the framework: three RKE2 servers
  (`Function = "rancher-server"`) and three RKE2 agents (`Function = "rancher-agent"`), one of each
  per availability zone (us-east-1a/b/c), on the CIS RHEL 9 STIG image, plus one internal network
  load balancer. Its listeners forward 80 and 443 to the agents, where the ingress controller runs,
  and 6443 and 9345 to the servers. Each node carries a 50 GiB data volume
  (`Function = "rancher-data"`) the playbook mounts at `/var/lib/rancher`, because the image's
  `/var` is 10 GiB. The OS instances are not swap-eligible (`refresh = false`).
- The framework SHA is pinned in `.github/terraform-framework-pin`.

`.github/workflows/aws-deploy.yml` checks the framework out at that pin, runs Terraform from
inside it, and passes this file with `-var-file`. The deployment identity (`environment`,
`repository`, `repository_id`, `commit_sha`, `run_id`) is supplied separately with `-var`, the
highest-precedence source, so the tags that satisfy the deploy role's create-time IAM conditions
cannot be overridden from here.

Reachability is **direct SSH over a launch-time public IPv4**: the shared subnet's
MapPublicIpOnLaunch assigns the address (no Elastic IP, no NAT), and at runtime the framework
attaches one security group scoped to the runner's validated public IPv4. Between the nodes, and
from the load balancer to them, peers are named by group, never by address: `rancher-node` and
`rancher-nlb` are standing groups declared in `dependencies/aws/estate.yml` and created by
`scripts/apply-dependencies.sh`, whose output prints the ids this file references. SSM (via the
instance profile's `AmazonSSMManagedInstanceCore`) is the administrator's backup connection, not
the primary path.
