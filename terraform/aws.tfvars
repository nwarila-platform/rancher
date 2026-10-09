# =========================================================================================== #
# File: 'terraform/aws.tfvars'
# --- [ Description ] ----------------------------------------------------------------------- #
#
# Variable input for the pinned aws-terraform-framework (SHA in .github/terraform-framework-pin).
# Plain tfvars — the workflow passes this file to terraform verbatim. This repository declares
# NO .tf files of its own: resources live in the pinned framework, configuration in the pinned
# ansible-framework plus this repository's roles.
#
# THE STACK — three RKE2 servers (etcd and control plane) and three RKE2 agents, one of each per
# availability zone, behind one internal network load balancer: 80 and 443 reach the agents, where
# the ingress controller runs; 6443 and 9345 reach the servers. Each node carries a 50 GiB data
# volume the playbook mounts at /var/lib/rancher, because the image's /var is 10 GiB.
#
# REACHABILITY — DIRECT SSH OVER A PUBLIC IPv4, as in every fleet repository: the framework's
# runner-scoped group carries SSH from the runner. Node to node and load balancer to node, peers
# are named by group, never by address: rancher-node and rancher-nlb are standing groups declared
# in dependencies/aws/estate.yml and created by scripts/apply-dependencies.sh.
#
# =========================================================================================== #

# environment and the deployment identity (repository, repository_id, commit_sha, run_id) are
# deliberately NOT in this file: the workflow passes them as -var flags placed AFTER this file on
# the command line, so it is that ordering that keeps this file from renaming the deployment.

all_systems = [
  {
    region                     = "us_east_1"
    hostname                   = "tcnaw-rancher-s01"
    availability_zone          = "us-east-1a"
    subnet_id                  = "subnet-0dbb7770d19f253ad"
    key_name                   = "nwarila-ec2-key"
    iam_instance_profile       = "nwarila-ec2-profile"
    aws_kms_alias              = "aws/ebs"
    ami                        = "ami-06d96912f6df33ee4"
    refresh                    = false
    instance_type              = "t3.large"
    connection_type            = "ssh"
    readiness_user             = "ec2-user"
    readiness_gate             = false
    readiness_command          = null
    readiness_script_dir       = null
    readiness_private_key_path = null
    imds_hop_limit             = 1
    set_state                  = null
    tags                       = {
      Function = "rancher-server"
      Backup   = false
    }
    root_block_device          = {
      iops        = null
      tags        = {}
      throughput  = null
      volume_type = "gp3"
      volume_size = "50"
    }
    ami_block_device_overrides = [
      {
        device_name = "/dev/sdf"
        iops        = "3000"
        throughput  = "125"
        volume_size = "40"
        volume_type = "gp3"
      }
    ]
    ebs_block_devices          = [
      {
        resource_key = "rancher-data"
        device_index = 0
        iops         = null
        snapshot_id  = null
        tags         = {
          Function = "rancher-data"
        }
        throughput   = null
        volume_size  = "50"
        volume_type  = "gp3"
      }
    ]
    network_interfaces         = [
      {
        description     = "tcnaw-rancher-s01 CI firewall"
        interface_type  = null
        private_ip      = null
        security_groups = ["sg-00c6392328bb10ee3"]
        ingress         = [
          {
            description                  = "All traffic from the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        egress          = [
          {
            description                  = "HTTPS out"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = "0.0.0.0/0"
            prefix_list_id               = null
            referenced_security_group_id = null
          },
          {
            description                  = "All traffic to the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        tags            = {}
      }
    ]
    associate_public_ip        = false
  },
  {
    region                     = "us_east_1"
    hostname                   = "tcnaw-rancher-s02"
    availability_zone          = "us-east-1b"
    subnet_id                  = "subnet-04260d6f543906b6b"
    key_name                   = "nwarila-ec2-key"
    iam_instance_profile       = "nwarila-ec2-profile"
    aws_kms_alias              = "aws/ebs"
    ami                        = "ami-06d96912f6df33ee4"
    refresh                    = false
    instance_type              = "t3.large"
    connection_type            = "ssh"
    readiness_user             = "ec2-user"
    readiness_gate             = false
    readiness_command          = null
    readiness_script_dir       = null
    readiness_private_key_path = null
    imds_hop_limit             = 1
    set_state                  = null
    tags                       = {
      Function = "rancher-server"
      Backup   = false
    }
    root_block_device          = {
      iops        = null
      tags        = {}
      throughput  = null
      volume_type = "gp3"
      volume_size = "50"
    }
    ami_block_device_overrides = [
      {
        device_name = "/dev/sdf"
        iops        = "3000"
        throughput  = "125"
        volume_size = "40"
        volume_type = "gp3"
      }
    ]
    ebs_block_devices          = [
      {
        resource_key = "rancher-data"
        device_index = 0
        iops         = null
        snapshot_id  = null
        tags         = {
          Function = "rancher-data"
        }
        throughput   = null
        volume_size  = "50"
        volume_type  = "gp3"
      }
    ]
    network_interfaces         = [
      {
        description     = "tcnaw-rancher-s02 CI firewall"
        interface_type  = null
        private_ip      = null
        security_groups = ["sg-00c6392328bb10ee3"]
        ingress         = [
          {
            description                  = "All traffic from the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        egress          = [
          {
            description                  = "HTTPS out"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = "0.0.0.0/0"
            prefix_list_id               = null
            referenced_security_group_id = null
          },
          {
            description                  = "All traffic to the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        tags            = {}
      }
    ]
    associate_public_ip        = false
  },
  {
    region                     = "us_east_1"
    hostname                   = "tcnaw-rancher-s03"
    availability_zone          = "us-east-1c"
    subnet_id                  = "subnet-03a855e712be7b399"
    key_name                   = "nwarila-ec2-key"
    iam_instance_profile       = "nwarila-ec2-profile"
    aws_kms_alias              = "aws/ebs"
    ami                        = "ami-06d96912f6df33ee4"
    refresh                    = false
    instance_type              = "t3.large"
    connection_type            = "ssh"
    readiness_user             = "ec2-user"
    readiness_gate             = false
    readiness_command          = null
    readiness_script_dir       = null
    readiness_private_key_path = null
    imds_hop_limit             = 1
    set_state                  = null
    tags                       = {
      Function = "rancher-server"
      Backup   = false
    }
    root_block_device          = {
      iops        = null
      tags        = {}
      throughput  = null
      volume_type = "gp3"
      volume_size = "50"
    }
    ami_block_device_overrides = [
      {
        device_name = "/dev/sdf"
        iops        = "3000"
        throughput  = "125"
        volume_size = "40"
        volume_type = "gp3"
      }
    ]
    ebs_block_devices          = [
      {
        resource_key = "rancher-data"
        device_index = 0
        iops         = null
        snapshot_id  = null
        tags         = {
          Function = "rancher-data"
        }
        throughput   = null
        volume_size  = "50"
        volume_type  = "gp3"
      }
    ]
    network_interfaces         = [
      {
        description     = "tcnaw-rancher-s03 CI firewall"
        interface_type  = null
        private_ip      = null
        security_groups = ["sg-00c6392328bb10ee3"]
        ingress         = [
          {
            description                  = "All traffic from the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        egress          = [
          {
            description                  = "HTTPS out"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = "0.0.0.0/0"
            prefix_list_id               = null
            referenced_security_group_id = null
          },
          {
            description                  = "All traffic to the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        tags            = {}
      }
    ]
    associate_public_ip        = false
  },
  {
    region                     = "us_east_1"
    hostname                   = "tcnaw-rancher-a01"
    availability_zone          = "us-east-1a"
    subnet_id                  = "subnet-0dbb7770d19f253ad"
    key_name                   = "nwarila-ec2-key"
    iam_instance_profile       = "nwarila-ec2-profile"
    aws_kms_alias              = "aws/ebs"
    ami                        = "ami-06d96912f6df33ee4"
    refresh                    = false
    instance_type              = "t3.large"
    connection_type            = "ssh"
    readiness_user             = "ec2-user"
    readiness_gate             = false
    readiness_command          = null
    readiness_script_dir       = null
    readiness_private_key_path = null
    imds_hop_limit             = 1
    set_state                  = null
    tags                       = {
      Function = "rancher-agent"
      Backup   = false
    }
    root_block_device          = {
      iops        = null
      tags        = {}
      throughput  = null
      volume_type = "gp3"
      volume_size = "50"
    }
    ami_block_device_overrides = [
      {
        device_name = "/dev/sdf"
        iops        = "3000"
        throughput  = "125"
        volume_size = "40"
        volume_type = "gp3"
      }
    ]
    ebs_block_devices          = [
      {
        resource_key = "rancher-data"
        device_index = 0
        iops         = null
        snapshot_id  = null
        tags         = {
          Function = "rancher-data"
        }
        throughput   = null
        volume_size  = "50"
        volume_type  = "gp3"
      }
    ]
    network_interfaces         = [
      {
        description     = "tcnaw-rancher-a01 CI firewall"
        interface_type  = null
        private_ip      = null
        security_groups = ["sg-00c6392328bb10ee3"]
        ingress         = [
          {
            description                  = "All traffic from the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        egress          = [
          {
            description                  = "HTTPS out"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = "0.0.0.0/0"
            prefix_list_id               = null
            referenced_security_group_id = null
          },
          {
            description                  = "All traffic to the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        tags            = {}
      }
    ]
    associate_public_ip        = false
  },
  {
    region                     = "us_east_1"
    hostname                   = "tcnaw-rancher-a02"
    availability_zone          = "us-east-1b"
    subnet_id                  = "subnet-04260d6f543906b6b"
    key_name                   = "nwarila-ec2-key"
    iam_instance_profile       = "nwarila-ec2-profile"
    aws_kms_alias              = "aws/ebs"
    ami                        = "ami-06d96912f6df33ee4"
    refresh                    = false
    instance_type              = "t3.large"
    connection_type            = "ssh"
    readiness_user             = "ec2-user"
    readiness_gate             = false
    readiness_command          = null
    readiness_script_dir       = null
    readiness_private_key_path = null
    imds_hop_limit             = 1
    set_state                  = null
    tags                       = {
      Function = "rancher-agent"
      Backup   = false
    }
    root_block_device          = {
      iops        = null
      tags        = {}
      throughput  = null
      volume_type = "gp3"
      volume_size = "50"
    }
    ami_block_device_overrides = [
      {
        device_name = "/dev/sdf"
        iops        = "3000"
        throughput  = "125"
        volume_size = "40"
        volume_type = "gp3"
      }
    ]
    ebs_block_devices          = [
      {
        resource_key = "rancher-data"
        device_index = 0
        iops         = null
        snapshot_id  = null
        tags         = {
          Function = "rancher-data"
        }
        throughput   = null
        volume_size  = "50"
        volume_type  = "gp3"
      }
    ]
    network_interfaces         = [
      {
        description     = "tcnaw-rancher-a02 CI firewall"
        interface_type  = null
        private_ip      = null
        security_groups = ["sg-00c6392328bb10ee3"]
        ingress         = [
          {
            description                  = "All traffic from the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        egress          = [
          {
            description                  = "HTTPS out"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = "0.0.0.0/0"
            prefix_list_id               = null
            referenced_security_group_id = null
          },
          {
            description                  = "All traffic to the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        tags            = {}
      }
    ]
    associate_public_ip        = false
  },
  {
    region                     = "us_east_1"
    hostname                   = "tcnaw-rancher-a03"
    availability_zone          = "us-east-1c"
    subnet_id                  = "subnet-03a855e712be7b399"
    key_name                   = "nwarila-ec2-key"
    iam_instance_profile       = "nwarila-ec2-profile"
    aws_kms_alias              = "aws/ebs"
    ami                        = "ami-06d96912f6df33ee4"
    refresh                    = false
    instance_type              = "t3.large"
    connection_type            = "ssh"
    readiness_user             = "ec2-user"
    readiness_gate             = false
    readiness_command          = null
    readiness_script_dir       = null
    readiness_private_key_path = null
    imds_hop_limit             = 1
    set_state                  = null
    tags                       = {
      Function = "rancher-agent"
      Backup   = false
    }
    root_block_device          = {
      iops        = null
      tags        = {}
      throughput  = null
      volume_type = "gp3"
      volume_size = "50"
    }
    ami_block_device_overrides = [
      {
        device_name = "/dev/sdf"
        iops        = "3000"
        throughput  = "125"
        volume_size = "40"
        volume_type = "gp3"
      }
    ]
    ebs_block_devices          = [
      {
        resource_key = "rancher-data"
        device_index = 0
        iops         = null
        snapshot_id  = null
        tags         = {
          Function = "rancher-data"
        }
        throughput   = null
        volume_size  = "50"
        volume_type  = "gp3"
      }
    ]
    network_interfaces         = [
      {
        description     = "tcnaw-rancher-a03 CI firewall"
        interface_type  = null
        private_ip      = null
        security_groups = ["sg-00c6392328bb10ee3"]
        ingress         = [
          {
            description                  = "All traffic from the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 from the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        egress          = [
          {
            description                  = "HTTPS out"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = "0.0.0.0/0"
            prefix_list_id               = null
            referenced_security_group_id = null
          },
          {
            description                  = "All traffic to the other Rancher nodes"
            ip_protocol                  = "-1"
            from_port                    = null
            to_port                      = null
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-00c6392328bb10ee3"
          },
          {
            description                  = "tcp/80 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 80
            to_port                      = 80
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 443
            to_port                      = 443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/6443 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 6443
            to_port                      = 6443
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          },
          {
            description                  = "tcp/9345 to the load balancer"
            ip_protocol                  = "tcp"
            from_port                    = 9345
            to_port                      = 9345
            cidr_ipv4                    = null
            prefix_list_id               = null
            referenced_security_group_id = "sg-0b00e049d7843c980"
          }
        ]
        tags            = {}
      }
    ]
    associate_public_ip        = false
  }
]
all_databases      = []
all_load_balancers = [
  {
    region                                                       = "us_east_1"
    resource_key                                                 = "rancher"
    name                                                         = "rancher"
    name_prefix                                                  = null
    security_groups                                              = ["sg-0b00e049d7843c980"]
    subnets                                                      = ["subnet-0dbb7770d19f253ad", "subnet-04260d6f543906b6b", "subnet-03a855e712be7b399"]
    subnet_mapping                                               = []
    access_logs                                                  = null
    client_keep_alive                                            = null
    connection_logs                                              = null
    customer_owned_ipv4_pool                                     = null
    desync_mitigation_mode                                       = null
    dns_record_client_routing_policy                             = null
    drop_invalid_header_fields                                   = null
    enable_cross_zone_load_balancing                             = true
    enable_deletion_protection                                   = false
    enable_http2                                                 = null
    enable_tls_version_and_cipher_suite_headers                  = null
    enable_waf_fail_open                                         = null
    enable_xff_client_port                                       = null
    enable_zonal_shift                                           = null
    enforce_security_group_inbound_rules_on_private_link_traffic = null
    health_check_logs                                            = null
    idle_timeout                                                 = null
    internal                                                     = true
    ip_address_type                                              = "ipv4"
    ipam_pools                                                   = null
    load_balancer_type                                           = "network"
    minimum_load_balancer_capacity                               = null
    preserve_host_header                                         = null
    secondary_ips_auto_assigned_per_subnet                       = null
    tags                                                         = {}
    timeouts                                                     = null
    xff_header_processing_mode                                   = null
    target_groups                                                = [
      {
        resource_key                      = "http"
        function                          = "rancher-agent"
        vpc_id                            = "vpc-0724440de2891a1ee"
        port                              = 80
        protocol                          = "TCP"
        deregistration_delay              = 30
        protocol_version                  = null
        target_type                       = "instance"
        slow_start                        = null
        load_balancing_algorithm_type     = null
        load_balancing_anomaly_mitigation = null
        load_balancing_cross_zone_enabled = null
        preserve_client_ip                = "false"
        proxy_protocol_v2                 = false
        connection_termination            = null
        ip_address_type                   = null
        health_check                      = {
          enabled             = true
          healthy_threshold   = 2
          interval            = 10
          matcher             = null
          path                = null
          port                = "traffic-port"
          protocol            = "TCP"
          timeout             = 5
          unhealthy_threshold = 2
        }
        stickiness                        = null
        tags                              = {}
      },
      {
        resource_key                      = "https"
        function                          = "rancher-agent"
        vpc_id                            = "vpc-0724440de2891a1ee"
        port                              = 443
        protocol                          = "TCP"
        deregistration_delay              = 30
        protocol_version                  = null
        target_type                       = "instance"
        slow_start                        = null
        load_balancing_algorithm_type     = null
        load_balancing_anomaly_mitigation = null
        load_balancing_cross_zone_enabled = null
        preserve_client_ip                = "false"
        proxy_protocol_v2                 = false
        connection_termination            = null
        ip_address_type                   = null
        health_check                      = {
          enabled             = true
          healthy_threshold   = 2
          interval            = 10
          matcher             = null
          path                = null
          port                = "traffic-port"
          protocol            = "TCP"
          timeout             = 5
          unhealthy_threshold = 2
        }
        stickiness                        = null
        tags                              = {}
      },
      {
        resource_key                      = "apiserver"
        function                          = "rancher-server"
        vpc_id                            = "vpc-0724440de2891a1ee"
        port                              = 6443
        protocol                          = "TCP"
        deregistration_delay              = 30
        protocol_version                  = null
        target_type                       = "instance"
        slow_start                        = null
        load_balancing_algorithm_type     = null
        load_balancing_anomaly_mitigation = null
        load_balancing_cross_zone_enabled = null
        preserve_client_ip                = "false"
        proxy_protocol_v2                 = false
        connection_termination            = null
        ip_address_type                   = null
        health_check                      = {
          enabled             = true
          healthy_threshold   = 2
          interval            = 10
          matcher             = null
          path                = null
          port                = "traffic-port"
          protocol            = "TCP"
          timeout             = 5
          unhealthy_threshold = 2
        }
        stickiness                        = null
        tags                              = {}
      },
      {
        resource_key                      = "supervisor"
        function                          = "rancher-server"
        vpc_id                            = "vpc-0724440de2891a1ee"
        port                              = 9345
        protocol                          = "TCP"
        deregistration_delay              = 30
        protocol_version                  = null
        target_type                       = "instance"
        slow_start                        = null
        load_balancing_algorithm_type     = null
        load_balancing_anomaly_mitigation = null
        load_balancing_cross_zone_enabled = null
        preserve_client_ip                = "false"
        proxy_protocol_v2                 = false
        connection_termination            = null
        ip_address_type                   = null
        health_check                      = {
          enabled             = true
          healthy_threshold   = 2
          interval            = 10
          matcher             = null
          path                = null
          port                = "traffic-port"
          protocol            = "TCP"
          timeout             = 5
          unhealthy_threshold = 2
        }
        stickiness                        = null
        tags                              = {}
      }
    ]
    listeners                                                    = [
      {
        resource_key                = "http"
        port                        = 80
        protocol                    = "TCP"
        ssl_policy                  = null
        alpn_policy                 = null
        certificate_arn             = null
        additional_certificate_arns = []
        default_action              = {
          type             = "forward"
          target_group_key = "http"
          redirect         = null
          fixed_response   = null
        }
        rules                       = []
      },
      {
        resource_key                = "https"
        port                        = 443
        protocol                    = "TCP"
        ssl_policy                  = null
        alpn_policy                 = null
        certificate_arn             = null
        additional_certificate_arns = []
        default_action              = {
          type             = "forward"
          target_group_key = "https"
          redirect         = null
          fixed_response   = null
        }
        rules                       = []
      },
      {
        resource_key                = "apiserver"
        port                        = 6443
        protocol                    = "TCP"
        ssl_policy                  = null
        alpn_policy                 = null
        certificate_arn             = null
        additional_certificate_arns = []
        default_action              = {
          type             = "forward"
          target_group_key = "apiserver"
          redirect         = null
          fixed_response   = null
        }
        rules                       = []
      },
      {
        resource_key                = "supervisor"
        port                        = 9345
        protocol                    = "TCP"
        ssl_policy                  = null
        alpn_policy                 = null
        certificate_arn             = null
        additional_certificate_arns = []
        default_action              = {
          type             = "forward"
          target_group_key = "supervisor"
          redirect         = null
          fixed_response   = null
        }
        rules                       = []
      }
    ]
  }
]
